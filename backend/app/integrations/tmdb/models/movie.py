"""Raw response models for TMDB movie-detail endpoints.

This module contains the Pydantic transport models used to deserialize the
top-level response returned by:

    GET /movie/{movie_id}

These models belong exclusively to Cineara's TMDB integration layer.

They represent factual metadata returned by TMDB and must not contain:

- Cineara media classifications;
- Search-specific behavior;
- generated image URLs;
- display formatting;
- cache state;
- persistence state;
- user-library information;
- presentation labels;
- application-specific business rules.

Raw TMDB movie data must be mapped into Cineara-owned domain or API models
before it leaves the backend integration boundary.

Shared TMDB transport structures such as genres, production companies,
production countries, and spoken languages are defined in ``common.py``.
Movie-specific structures remain in this module.

Design principles
-----------------
1. Preserve TMDB's data shape.

   These models describe upstream TMDB data rather than Cineara's public API.

2. Keep artwork as raw TMDB paths.

   Fields such as ``poster_path``, ``backdrop_path``, and ``logo_path`` remain
   relative paths. Final image URLs are constructed by ``image_url.py``.

3. Keep dates as strings.

   TMDB may return missing or empty dates for incomplete catalogue entries.
   Parsing and presentation belong to higher application layers.

4. Handle optional metadata defensively.

   Metadata that may legitimately be missing should not cause the complete
   movie response to fail validation.

5. Ignore unknown upstream fields.

   The shared ``TmdbModel`` base ignores additive upstream fields so unrelated
   TMDB response changes do not break Cineara's integration.

6. Keep derived Cineara semantics outside this module.

   Normalized genres, country metadata, runtime formatting, certification, and
   media classification belong in mapper, catalogue, or feature layers.

7. Keep top-level movie details independent of subordinate endpoints.

   Credits, images, videos, release dates, recommendations, watch providers,
   external IDs, and other movie resources use their own raw response models.
"""

from __future__ import annotations

from pydantic import Field

from .common import (
    TmdbGenre,
    TmdbModel,
    TmdbProductionCompany,
    TmdbProductionCountry,
    TmdbSpokenLanguage,
)

# =============================================================================
# Collection summary
# =============================================================================


class TmdbMovieCollectionSummary(TmdbModel):
    """Lightweight collection summary embedded in movie details.

    TMDB exposes this structure through ``belongs_to_collection``.

    It is distinct from the complete collection response returned by TMDB's
    collection-details endpoint.
    """

    id: int = Field(
        gt=0,
    )

    name: str

    poster_path: str | None = None

    backdrop_path: str | None = None


# =============================================================================
# Movie details
# =============================================================================


class TmdbMovieDetails(TmdbModel):
    """Top-level raw response from ``GET /movie/{movie_id}``.

    The model contains only metadata returned directly by TMDB's movie-details
    endpoint. It does not perform classification, URL construction, caching,
    persistence, or additional TMDB requests.

    Search must use TMDB Search response models rather than requesting movie
    details for individual Search results.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int = Field(
        gt=0,
    )

    # =========================================================================
    # Titles
    # =========================================================================

    title: str

    original_title: str

    # =========================================================================
    # Language and origin
    # =========================================================================

    original_language: str | None = None

    origin_country: list[str] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Description
    # =========================================================================

    overview: str | None = None

    tagline: str | None = None

    # =========================================================================
    # Artwork
    # =========================================================================
    #
    # Values remain raw TMDB paths such as:
    #
    #     /abc123.jpg
    #
    # URL construction belongs in ``image_url.py``.
    # =========================================================================

    poster_path: str | None = None

    backdrop_path: str | None = None

    # =========================================================================
    # Genres
    # =========================================================================

    genres: list[TmdbGenre] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Release metadata
    # =========================================================================

    release_date: str | None = None

    status: str | None = None

    # =========================================================================
    # Runtime
    # =========================================================================
    #
    # TMDB expresses movie runtime in minutes. Zero is accepted because TMDB
    # may use it when no meaningful runtime is available.
    # =========================================================================

    runtime: int | None = Field(
        default=None,
        ge=0,
    )

    # =========================================================================
    # Production metadata
    # =========================================================================

    production_companies: list[TmdbProductionCompany] = Field(
        default_factory=list,
    )

    production_countries: list[TmdbProductionCountry] = Field(
        default_factory=list,
    )

    spoken_languages: list[TmdbSpokenLanguage] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Collection relationship
    # =========================================================================

    belongs_to_collection: TmdbMovieCollectionSummary | None = None

    # =========================================================================
    # Financial metadata
    # =========================================================================
    #
    # TMDB reports budget and revenue as whole currency units and commonly
    # uses zero when the value is unavailable.
    # =========================================================================

    budget: int = Field(
        default=0,
        ge=0,
    )

    revenue: int = Field(
        default=0,
        ge=0,
    )

    # =========================================================================
    # External metadata
    # =========================================================================

    homepage: str | None = None

    imdb_id: str | None = None

    # =========================================================================
    # Content flags
    # =========================================================================

    adult: bool = False

    video: bool = False

    # =========================================================================
    # TMDB ranking / rating metadata
    # =========================================================================

    popularity: float = 0.0

    vote_average: float = 0.0

    vote_count: int = Field(
        default=0,
        ge=0,
    )
