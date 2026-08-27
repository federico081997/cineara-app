"""FastAPI dependency providers for Cineara application services.

Application resources are created once during the FastAPI lifespan and stored
on ``app.state``. Request dependencies retrieve those resources without
constructing new HTTP clients, Redis pools, or feature services per request.

This module owns dependency access only. Resource construction and shutdown
belong to ``app.main``.
"""

from __future__ import annotations

from fastapi import Request

from app.core.cache import KeyValueCache
from app.core.config import Settings
from app.integrations.tmdb import TmdbClient
from app.modules.search.service import SearchService

# =============================================================================
# State keys
# =============================================================================


_SETTINGS_STATE_KEY = "settings"
_TMDB_CLIENT_STATE_KEY = "tmdb_client"
_CACHE_STATE_KEY = "cache"
_SEARCH_SERVICE_STATE_KEY = "search_service"


# =============================================================================
# Public dependencies
# =============================================================================


def get_settings(
    request: Request,
) -> Settings:
    """Return the application-scoped validated settings."""

    return _require_state(
        request,
        name=_SETTINGS_STATE_KEY,
        expected_type=Settings,
    )


def get_tmdb_client(
    request: Request,
) -> TmdbClient:
    """Return the application-scoped TMDB client."""

    return _require_state(
        request,
        name=_TMDB_CLIENT_STATE_KEY,
        expected_type=TmdbClient,
    )


def get_cache(
    request: Request,
) -> KeyValueCache:
    """Return the application-scoped cache through its stable protocol."""

    value = _require_untyped_state(
        request,
        name=_CACHE_STATE_KEY,
    )

    if not isinstance(
        value,
        KeyValueCache,
    ):
        raise RuntimeError(
            "Application state 'cache' does not implement KeyValueCache."
        )

    return value


def get_search_service(
    request: Request,
) -> SearchService:
    """Return the application-scoped Search service."""

    return _require_state(
        request,
        name=_SEARCH_SERVICE_STATE_KEY,
        expected_type=SearchService,
    )


# =============================================================================
# State access
# =============================================================================


def _require_state[StateT](
    request: Request,
    *,
    name: str,
    expected_type: type[StateT],
) -> StateT:
    """Return one typed application-state resource.

    A missing or incorrectly typed resource indicates an application lifecycle
    or bootstrap error rather than a client request error.
    """

    value = _require_untyped_state(
        request,
        name=name,
    )

    if not isinstance(
        value,
        expected_type,
    ):
        raise RuntimeError(
            f"Application state {name!r} has unexpected type "
            f"{type(value).__name__!r}; expected "
            f"{expected_type.__name__!r}."
        )

    return value


def _require_untyped_state(
    request: Request,
    *,
    name: str,
) -> object:
    """Return a required application-state value."""

    state = request.app.state

    if not hasattr(
        state,
        name,
    ):
        raise RuntimeError(
            f"Required application resource {name!r} is not initialized."
        )

    return getattr(
        state,
        name,
    )
