"""Public exports for Cineara's HTTP API package.

The ``api`` package owns application-level HTTP composition and dependency
providers.

Feature modules define their own routers and HTTP contracts. This package
assembles those feature routers under the versioned Cineara API prefix and
provides access to application-scoped dependencies.

Importing this package does not construct application resources or perform
network operations.
"""

from __future__ import annotations

from .dependencies import (
    get_cache,
    get_search_service,
    get_settings,
    get_tmdb_client,
)
from .router import api_router

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "api_router",
    "get_cache",
    "get_search_service",
    "get_settings",
    "get_tmdb_client",
]
