"""Public exports for TMDB endpoint groups.

This package contains thin resource-oriented wrappers around TMDB API
endpoints. Endpoint groups own:

- TMDB endpoint paths;
- endpoint-specific parameter construction;
- endpoint-level validation;
- selection of raw TMDB response models.

They do not own:

- HTTP transport behavior;
- retries;
- caching;
- Cineara domain or API models;
- media classification;
- persistence;
- application-level orchestration.

The package root re-exports the stable endpoint-group classes used by
``TmdbClient`` and integration tests.

Importing this package performs no network requests and creates no client
instances.
"""

from __future__ import annotations

from .movies import TmdbMovieEndpoints
from .search import TmdbSearchEndpoints
from .trending import (
    TmdbTrendingEndpoints,
    TmdbTrendingTimeWindow,
)
from .tv import TmdbTvEndpoints

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "TmdbMovieEndpoints",
    "TmdbSearchEndpoints",
    "TmdbTrendingEndpoints",
    "TmdbTrendingTimeWindow",
    "TmdbTvEndpoints",
]
