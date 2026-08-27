"""Public application-level exports for Cineara Search.

The Search package separates its responsibilities across:

- ``schemas`` for the provider-independent Search API contract;
- ``mapper`` for deterministic provider-to-Cineara transformation;
- ``cache_keys`` for internal versioned cache-key construction;
- ``service`` for Search orchestration and cache usage;
- ``api`` for FastAPI routes.

This package root exposes the stable application-facing Search types used by
other Cineara modules.

HTTP routing is intentionally not imported here. Application router assembly
should import ``app.modules.search.api`` directly. Keeping the HTTP layer out
of the package root prevents dependency cycles between Search routes and
application dependency providers.

Cache-key helpers are also intentionally internal to the Search feature and are
therefore not re-exported here.
"""

from __future__ import annotations

from .mapper import SearchMapper
from .schemas import (
    CollectionSearchResult,
    ExternalRating,
    ExternalRatingSource,
    KnownForSearchItem,
    MediaSearchResult,
    MovieSearchResult,
    PersonSearchResult,
    SearchCategory,
    SearchLanding,
    SearchMediaClassification,
    SearchOverview,
    SearchOverviewSection,
    SearchPage,
    SearchResult,
    SearchResultType,
    StudioSearchResult,
    TopicSearchResult,
    TrendingSearchResult,
    TvSearchResult,
)
from .service import SearchService

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "CollectionSearchResult",
    "ExternalRating",
    "ExternalRatingSource",
    "KnownForSearchItem",
    "MediaSearchResult",
    "MovieSearchResult",
    "PersonSearchResult",
    "SearchCategory",
    "SearchLanding",
    "SearchMapper",
    "SearchMediaClassification",
    "SearchOverview",
    "SearchOverviewSection",
    "SearchPage",
    "SearchResult",
    "SearchResultType",
    "SearchService",
    "StudioSearchResult",
    "TopicSearchResult",
    "TrendingSearchResult",
    "TvSearchResult",
]
