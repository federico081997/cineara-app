"""Cineara FastAPI application entry point.

The application lifespan owns long-lived infrastructure resources:

- one shared ``httpx.AsyncClient`` used by the TMDB integration;
- one application-scoped ``TmdbClient``;
- one Redis-backed cache adapter;
- one application-scoped ``SearchService``.

Request dependencies read these objects from ``app.state``. No request creates
its own HTTP connection pool or Redis connection pool.

The versioned feature API is assembled by ``app.api.router``.
"""

from __future__ import annotations

import asyncio
import logging
from collections.abc import AsyncIterator, Awaitable
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI, Response, status
from pydantic import BaseModel, ConfigDict

from app.api.router import api_router
from app.core.cache import (
    CacheError,
    RedisCache,
)
from app.core.config import (
    DependencyStatus,
    Settings,
    check_postgres_ready,
    get_settings,
)
from app.integrations.tmdb import TmdbClient
from app.modules.search.mapper import SearchMapper
from app.modules.search.service import SearchService

logger = logging.getLogger(__name__)


# =============================================================================
# Health response models
# =============================================================================


class HealthResponse(BaseModel):
    """Unconditional process-liveness response."""

    model_config = ConfigDict(
        extra="forbid",
        frozen=True,
    )

    status: str = "ok"


class ReadinessResponse(BaseModel):
    """Infrastructure-readiness response."""

    model_config = ConfigDict(
        extra="forbid",
        frozen=True,
    )

    status: str
    dependencies: DependencyStatus


# =============================================================================
# Application lifespan
# =============================================================================


@asynccontextmanager
async def lifespan(
    fastapi_app: FastAPI,
) -> AsyncIterator[None]:
    """Create, expose, and close application-scoped resources."""

    settings = get_settings()

    logging.getLogger().setLevel(
        settings.log_level,
    )

    cleanup_http_client: httpx.AsyncClient | None = None
    cleanup_tmdb_client: TmdbClient | None = None
    cleanup_cache: RedisCache | None = None

    try:
        http_client = _create_http_client(
            settings,
        )
        cleanup_http_client = http_client

        tmdb_client = _create_tmdb_client(
            settings=settings,
            http_client=http_client,
        )
        cleanup_tmdb_client = tmdb_client

        cache = _create_cache(
            settings,
        )
        cleanup_cache = cache

        search_service = _create_search_service(
            settings=settings,
            tmdb_client=tmdb_client,
            cache=cache,
        )

        fastapi_app.state.settings = settings
        fastapi_app.state.tmdb_http_client = http_client
        fastapi_app.state.tmdb_client = tmdb_client
        fastapi_app.state.cache = cache
        fastapi_app.state.search_service = search_service

        yield

    finally:
        await _shutdown_resources(
            tmdb_client=cleanup_tmdb_client,
            http_client=cleanup_http_client,
            cache=cleanup_cache,
        )


# =============================================================================
# Resource construction
# =============================================================================


def _create_http_client(
    settings: Settings,
) -> httpx.AsyncClient:
    """Create the shared asynchronous HTTP client."""

    return httpx.AsyncClient(
        limits=httpx.Limits(
            max_connections=settings.tmdb_max_connections,
            max_keepalive_connections=(
                settings.tmdb_max_keepalive_connections
            ),
        ),
    )


def _create_tmdb_client(
    *,
    settings: Settings,
    http_client: httpx.AsyncClient,
) -> TmdbClient:
    """Create the application-scoped TMDB integration client."""

    return TmdbClient(
        access_token=settings.tmdb_read_access_token,
        base_url=settings.tmdb_base_url,
        language=settings.tmdb_language,
        timeout_seconds=settings.tmdb_request_timeout_seconds,
        http_client=http_client,
    )


def _create_cache(
    settings: Settings,
) -> RedisCache:
    """Create the application-scoped Redis cache adapter."""

    return RedisCache.from_url(
        settings.redis_url,
        key_prefix=settings.effective_redis_key_prefix,
        decode_responses=settings.redis_decode_responses,
        socket_timeout_seconds=settings.redis_socket_timeout_seconds,
        socket_connect_timeout_seconds=(
            settings.redis_socket_connect_timeout_seconds
        ),
        health_check_interval_seconds=(
            settings.redis_health_check_interval_seconds
        ),
        max_connections=settings.redis_max_connections,
    )


def _create_search_service(
    *,
    settings: Settings,
    tmdb_client: TmdbClient,
    cache: RedisCache,
) -> SearchService:
    """Create the application-scoped Search service."""

    return SearchService(
        tmdb=tmdb_client,
        cache=cache,
        mapper=SearchMapper(),
        include_adult=settings.tmdb_include_adult,
        min_query_length=settings.search_min_query_length,
        search_cache_ttl_seconds=settings.search_cache_ttl_seconds,
        overview_cache_ttl_seconds=(
            settings.search_overview_cache_ttl_seconds
        ),
        landing_cache_ttl_seconds=settings.search_landing_cache_ttl_seconds,
        overview_section_limit=settings.search_overview_section_limit,
        trending_limit=settings.search_trending_limit,
        trending_time_window=settings.search_trending_time_window,
    )


# =============================================================================
# Application
# =============================================================================


app = FastAPI(
    title="Cineara API",
    version="0.1.0",
    description="Backend API for Cineara.",
    lifespan=lifespan,
)

app.include_router(
    api_router,
)


# =============================================================================
# Liveness
# =============================================================================


@app.get(
    "/health",
    response_model=HealthResponse,
    tags=[
        "Infrastructure",
    ],
    summary="Check API liveness",
)
async def health() -> HealthResponse:
    """Return success while the FastAPI process is serving requests."""

    return HealthResponse()


# =============================================================================
# Readiness
# =============================================================================


@app.get(
    "/ready",
    response_model=ReadinessResponse,
    tags=[
        "Infrastructure",
    ],
    summary="Check required infrastructure",
)
async def readiness(
    response: Response,
) -> ReadinessResponse:
    """Check whether PostgreSQL and Redis are reachable."""

    settings: Settings = app.state.settings
    cache: RedisCache = app.state.cache

    postgres_ready, redis_ready = await asyncio.gather(
        check_postgres_ready(
            settings,
        ),
        _check_cache_ready(
            cache,
        ),
    )

    dependencies = DependencyStatus(
        postgres=postgres_ready,
        redis=redis_ready,
    )

    if not dependencies.ready:
        response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE

    return ReadinessResponse(
        status=("ready" if dependencies.ready else "not_ready"),
        dependencies=dependencies,
    )


# =============================================================================
# Readiness helpers
# =============================================================================


async def _check_cache_ready(
    cache: RedisCache,
) -> bool:
    """Return whether the application-scoped Redis cache responds to PING."""

    try:
        return await cache.ping()

    except CacheError:
        logger.warning(
            "Redis readiness check failed.",
            exc_info=True,
        )

        return False


# =============================================================================
# Shutdown
# =============================================================================


async def _shutdown_resources(
    *,
    tmdb_client: TmdbClient | None,
    http_client: httpx.AsyncClient | None,
    cache: RedisCache | None,
) -> None:
    """Close initialized application resources.

    Each shutdown operation is isolated so failure while closing one resource
    does not prevent the remaining resources from being released.

    ``TmdbClient`` does not close an externally supplied HTTP client, so the
    shared ``httpx.AsyncClient`` is closed separately by the application.
    """

    resources: list[
        tuple[
            str,
            Awaitable[None],
        ]
    ] = []

    if tmdb_client is not None:
        resources.append(
            (
                "TMDB client",
                tmdb_client.aclose(),
            )
        )

    if http_client is not None:
        resources.append(
            (
                "shared HTTP client",
                http_client.aclose(),
            )
        )

    if cache is not None:
        resources.append(
            (
                "Redis cache",
                cache.aclose(),
            )
        )

    if not resources:
        return

    results = await asyncio.gather(
        *(operation for _, operation in resources),
        return_exceptions=True,
    )

    for (
        resource_name,
        _,
    ), result in zip(
        resources,
        results,
        strict=True,
    ):
        if not isinstance(
            result,
            BaseException,
        ):
            continue

        logger.error(
            "Failed to close %s.",
            resource_name,
            exc_info=(
                type(result),
                result,
                result.__traceback__,
            ),
        )
