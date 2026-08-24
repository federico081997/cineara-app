"""Cineara FastAPI application entry point.

This module owns application-lifetime infrastructure.

Long-lived resources are created once when FastAPI starts and reused across
requests:

    shared HTTPX AsyncClient
        ↓
    TmdbClient

    shared Redis client / connection pool
        ↓
    Cache

Feature modules retrieve the shared application-scoped objects through:

    request.app.state.tmdb_client
    request.app.state.cache

The lower-level clients are also retained on ``app.state`` for infrastructure
that may legitimately reuse them:

    request.app.state.http_client
    request.app.state.redis

This prevents Cineara from creating new HTTP or Redis connection pools for
individual Search requests.

Search architecture
-------------------

Search now performs automatic cache-first selective enrichment internally:

    GET /api/v1/search
        ↓
    TMDB Search
        ↓
    classify Search metadata
        ↓
    Redis facts/details cache
        ↓
    selectively fetch /movie/{id} or /tv/{id} only when needed
        ↓
    final Cineara Search response

There is no longer a public ``POST /api/v1/search/enrich`` route.
"""

from __future__ import annotations

from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

import httpx
from fastapi import FastAPI
from redis.asyncio import Redis

from app.api.router import api_router
from app.core.config import get_settings
from app.integrations.redis.cache import Cache
from app.integrations.tmdb.client import TmdbClient

# =============================================================================
# Application lifespan
# =============================================================================


@asynccontextmanager
async def lifespan(
    app: FastAPI,
) -> AsyncIterator[None]:
    """Create and clean up application-scoped infrastructure.

    Resources created here live for the complete FastAPI application lifetime.

    Startup
    -------

        Settings
            ↓
        shared HTTPX AsyncClient
            ↓
        TmdbClient

        shared Redis client
            ↓
        Cache

    Shutdown
    --------

        TmdbClient marked closed
            ↓
        shared HTTPX connection pool closed
            ↓
        shared Redis connection pool closed

    Redis availability
    ------------------
    Redis is intentionally not ``PING``ed here.

    Search treats caching as an optimization. Cache read/write failures are
    handled at the feature layer and should not prevent Cineara from using TMDB
    directly.

    Infrastructure/readiness endpoints may perform their own Redis health
    checks without turning application startup into a hard Redis dependency.
    """

    settings = get_settings()

    # =========================================================================
    # Shared HTTPX client
    # =========================================================================
    #
    # One AsyncClient owns one reusable connection pool for the application
    # lifetime.
    #
    # It is injected into TmdbClient. Because the HTTP client is externally
    # managed, TmdbClient will not close it itself.
    # =========================================================================

    http_client = httpx.AsyncClient()

    # =========================================================================
    # Shared Redis client
    # =========================================================================
    #
    # redis.asyncio.Redis owns/reuses its internal connection pool.
    #
    # ``decode_responses=True`` makes Redis string values arrive as Python
    # strings. Cineara's Cache abstraction also supports bytes defensively.
    # =========================================================================

    redis_client = Redis(
        host=settings.redis_host,
        port=settings.redis_port,
        decode_responses=True,
    )

    # Keep references nullable until construction succeeds so shutdown remains
    # safe if application initialization raises midway through startup.
    tmdb_client: TmdbClient | None = None

    try:
        # =====================================================================
        # TMDB integration
        # =====================================================================

        tmdb_client = TmdbClient(
            access_token=settings.tmdb_access_token,
            base_url=settings.tmdb_base_url,
            language=settings.tmdb_language,
            timeout_seconds=settings.tmdb_request_timeout_seconds,
            http_client=http_client,
        )

        # =====================================================================
        # Generic Redis-backed cache
        # =====================================================================
        #
        # Cache deliberately remains independent from TMDB/Search/domain
        # models. Feature layers own cache-key design and TTL policy.
        # =====================================================================

        cache = Cache(
            redis_client,
        )

        # =====================================================================
        # Application state
        # =====================================================================
        #
        # Search and other feature dependencies use:
        #
        #     request.app.state.tmdb_client
        #     request.app.state.cache
        #
        # Lower-level clients are retained for infrastructure components that
        # legitimately require them.
        # =====================================================================

        app.state.http_client = http_client
        app.state.redis = redis_client

        app.state.tmdb_client = tmdb_client
        app.state.cache = cache

        # =====================================================================
        # Application runs here
        # =====================================================================

        yield

    finally:
        # =====================================================================
        # Shutdown
        # =====================================================================
        #
        # TmdbClient received an externally managed HTTPX client. Closing the
        # integration client therefore marks TmdbClient closed while leaving
        # the actual HTTPX pool for this lifespan owner to close.
        #
        # Each resource is closed by the layer that created/owns it.
        # =====================================================================

        if tmdb_client is not None:
            await tmdb_client.aclose()

        await http_client.aclose()
        await redis_client.aclose()


# =============================================================================
# Application factory
# =============================================================================


def create_app() -> FastAPI:
    """Create and configure the Cineara FastAPI application."""

    settings = get_settings()

    application = FastAPI(
        title="Cineara API",
        description=(
            "Backend API for the Cineara movie, TV and anime "
            "tracking application."
        ),
        version="0.1.0",
        debug=settings.debug,
        lifespan=lifespan,
    )

    # =========================================================================
    # API
    # =========================================================================
    #
    # ``api_router`` owns the application's versioned API prefix:
    #
    #     /api/v1
    #
    # Search owns:
    #
    #     /search
    #
    # Therefore the Search route is:
    #
    #     GET /api/v1/search
    #
    # Search enrichment is now automatic and internal; there is deliberately
    # no public ``POST /api/v1/search/enrich`` endpoint.
    # =========================================================================

    application.include_router(
        api_router,
    )

    return application


# =============================================================================
# ASGI application
# =============================================================================


app = create_app()

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "app",
    "create_app",
    "lifespan",
]
