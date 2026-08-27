"""Public exports for raw TMDB transport models.

This package contains Pydantic models and type aliases used to deserialize
responses returned directly by TMDB APIs.

The package root re-exports the stable raw transport types that are useful
across Cineara's TMDB endpoint modules and integration tests.

These models belong exclusively to the TMDB integration boundary. They must
not contain or expose:

- Cineara domain models;
- media classification;
- presentation models;
- generated image URLs;
- cache state;
- persistence state;
- user-library state;
- application-level Search semantics.

Application and feature layers should consume Cineara-owned models produced by
mappers rather than depending directly on these raw TMDB transport models.
"""

from __future__ import annotations

from .common import (
    TmdbGenre,
    TmdbModel,
    TmdbPage,
    TmdbProductionCompany,
    TmdbProductionCountry,
    TmdbSpokenLanguage,
)
from .movie import (
    TmdbMovieCollectionSummary,
    TmdbMovieDetails,
)
from .search import (
    TmdbCollectionSearchResult,
    TmdbCompanySearchResult,
    TmdbKeywordSearchResult,
    TmdbKnownForResult,
    TmdbMovieSearchResult,
    TmdbMultiSearchResult,
    TmdbPersonSearchResult,
    TmdbTvSearchResult,
)
from .tv import (
    TmdbTvCreator,
    TmdbTvDetails,
    TmdbTvEpisodeSummary,
    TmdbTvNetwork,
    TmdbTvSeasonSummary,
)

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "TmdbCollectionSearchResult",
    "TmdbCompanySearchResult",
    "TmdbGenre",
    "TmdbKeywordSearchResult",
    "TmdbKnownForResult",
    "TmdbModel",
    "TmdbMovieCollectionSummary",
    "TmdbMovieDetails",
    "TmdbMovieSearchResult",
    "TmdbMultiSearchResult",
    "TmdbPage",
    "TmdbPersonSearchResult",
    "TmdbProductionCompany",
    "TmdbProductionCountry",
    "TmdbSpokenLanguage",
    "TmdbTvCreator",
    "TmdbTvDetails",
    "TmdbTvEpisodeSummary",
    "TmdbTvNetwork",
    "TmdbTvSearchResult",
    "TmdbTvSeasonSummary",
]
