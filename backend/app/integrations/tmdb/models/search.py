"""Raw TMDB Search response models.

These models represent data received directly from TMDB Search endpoints.

They belong exclusively to the TMDB integration layer and must not be exposed
directly to the Cineara Flutter application. Cineara-owned Search models should
be produced by the backend Search mapping/orchestration layer.

Supported endpoints
-------------------

    GET /search/movie
    GET /search/tv
    GET /search/person
    GET /search/multi

Design principles
-----------------

1. Search models describe Search payloads only.

   Do not add richer detail-only fields such as:

       TV ``type``
       movie ``production_countries``
       runtime
       number_of_seasons

   Those belong to ``movie.py`` / ``tv.py`` and are obtained only when
   selective detail enrichment is required.

2. Dates remain strings.

   Search/list payloads can contain empty, missing, or incomplete date values.
   Cineara derives years later in its mapping layer.

3. Artwork remains as raw TMDB paths.

   Final image URLs are built by ``image_url.py``.

4. ``media_type`` is normalized onto all three result models.

   ``/search/multi`` supplies this discriminator. Dedicated endpoints do not
   need to supply it, so Cineara gives each model its natural default.

5. Unknown upstream fields are ignored.

   TMDB can add unrelated response fields without breaking Cineara.

6. TV ``origin_country`` is factual Search metadata.

   It may safely contribute to:

       country display
       high-confidence Anime detection
       selective regional-drama enrichment candidate detection

   It is NOT sufficient by itself to classify a result as K-Drama, J-Drama,
   C-Drama, etc. Those labels require richer TV-detail metadata.

7. Search pagination is generic.

8. Person ``known_for`` entries remain strongly typed.

Selective enrichment
--------------------
These models intentionally do not know whether a result should be enriched.
That decision belongs to Cineara's Search/classification orchestration.

Examples:

    Japanese-language animated movie with missing production countries
        -> Search model remains unchanged
        -> classifier may mark NEEDS_ENRICHMENT
        -> movie details can be fetched/cache-reused

    Japanese Drama TV Search result without TV ``type``
        -> Search model remains unchanged
        -> classifier may mark NEEDS_ENRICHMENT
        -> TV details can be fetched/cache-reused
"""

from __future__ import annotations

from typing import Annotated, Literal, TypeVar

from pydantic import BaseModel, ConfigDict, Field

# =============================================================================
# Base model
# =============================================================================


class _TmdbSearchModel(BaseModel):
    """Base configuration shared by raw TMDB Search models."""

    model_config = ConfigDict(
        # TMDB may add fields without requiring an immediate Cineara release.
        extra="ignore",
    )


# =============================================================================
# Movie Search result
# =============================================================================


class TmdbMovieSearchResult(_TmdbSearchModel):
    """Raw TMDB movie Search result.

    Used by:

        GET /search/movie

    and movie entries returned by:

        GET /search/multi
        person.known_for

    Movie Search does not contain the richer production-country data used by
    Cineara for high-confidence Anime classification. That data belongs to
    ``TmdbMovieDetails`` and can be obtained through selective enrichment.
    """

    # -------------------------------------------------------------------------
    # Multi-search discriminator
    # -------------------------------------------------------------------------

    media_type: Literal["movie"] = "movie"

    # -------------------------------------------------------------------------
    # Identity
    # -------------------------------------------------------------------------

    id: int

    # -------------------------------------------------------------------------
    # Titles
    # -------------------------------------------------------------------------

    title: str
    original_title: str

    # -------------------------------------------------------------------------
    # Language
    # -------------------------------------------------------------------------

    original_language: str | None = None

    # -------------------------------------------------------------------------
    # Description
    # -------------------------------------------------------------------------

    overview: str = ""

    # -------------------------------------------------------------------------
    # Artwork
    # -------------------------------------------------------------------------

    poster_path: str | None = None
    backdrop_path: str | None = None

    # -------------------------------------------------------------------------
    # Search-level classification metadata
    # -------------------------------------------------------------------------

    genre_ids: list[int] = Field(
        default_factory=list,
    )

    # -------------------------------------------------------------------------
    # Release metadata
    # -------------------------------------------------------------------------

    release_date: str | None = None

    # -------------------------------------------------------------------------
    # Content flags
    # -------------------------------------------------------------------------

    adult: bool = False
    video: bool = False

    # -------------------------------------------------------------------------
    # TMDB ranking/rating metadata
    # -------------------------------------------------------------------------

    popularity: float = 0.0
    vote_average: float = 0.0
    vote_count: int = Field(
        default=0,
        ge=0,
    )


# =============================================================================
# TV Search result
# =============================================================================


class TmdbTvSearchResult(_TmdbSearchModel):
    """Raw TMDB television Search result.

    Used by:

        GET /search/tv

    and TV entries returned by:

        GET /search/multi
        person.known_for

    ``origin_country`` is useful for country display, Anime classification,
    and detecting whether a result is worth selectively enriching.

    Regional-drama classifications are deliberately NOT inferred from country
    alone. Cineara requires richer TV-detail metadata such as ``type`` before
    applying K-Drama, J-Drama, C-Drama, etc.

    Likewise, this Search model does not contain enough information to decide
    reliably whether a TV item is a Series or Miniseries. That structural
    distinction belongs to ``TmdbTvDetails``.
    """

    # -------------------------------------------------------------------------
    # Multi-search discriminator
    # -------------------------------------------------------------------------

    media_type: Literal["tv"] = "tv"

    # -------------------------------------------------------------------------
    # Identity
    # -------------------------------------------------------------------------

    id: int

    # -------------------------------------------------------------------------
    # Names
    # -------------------------------------------------------------------------

    name: str
    original_name: str

    # -------------------------------------------------------------------------
    # Language/origin
    # -------------------------------------------------------------------------

    original_language: str | None = None

    origin_country: list[str] = Field(
        default_factory=list,
    )

    # -------------------------------------------------------------------------
    # Description
    # -------------------------------------------------------------------------

    overview: str = ""

    # -------------------------------------------------------------------------
    # Artwork
    # -------------------------------------------------------------------------

    poster_path: str | None = None
    backdrop_path: str | None = None

    # -------------------------------------------------------------------------
    # Search-level classification metadata
    # -------------------------------------------------------------------------

    genre_ids: list[int] = Field(
        default_factory=list,
    )

    # -------------------------------------------------------------------------
    # Air-date metadata
    # -------------------------------------------------------------------------

    first_air_date: str | None = None

    # -------------------------------------------------------------------------
    # Content flags
    # -------------------------------------------------------------------------

    adult: bool = False

    # -------------------------------------------------------------------------
    # TMDB ranking/rating metadata
    # -------------------------------------------------------------------------

    popularity: float = 0.0
    vote_average: float = 0.0
    vote_count: int = Field(
        default=0,
        ge=0,
    )


# =============================================================================
# Known-for result
# =============================================================================


type _TmdbKnownForResult = Annotated[
    TmdbMovieSearchResult | TmdbTvSearchResult,
    Field(
        discriminator="media_type",
    ),
]


# =============================================================================
# Person Search result
# =============================================================================


class TmdbPersonSearchResult(_TmdbSearchModel):
    """Raw TMDB person Search result.

    Used by:

        GET /search/person

    and person entries returned by:

        GET /search/multi
    """

    # -------------------------------------------------------------------------
    # Multi-search discriminator
    # -------------------------------------------------------------------------

    media_type: Literal["person"] = "person"

    # -------------------------------------------------------------------------
    # Identity
    # -------------------------------------------------------------------------

    id: int

    # -------------------------------------------------------------------------
    # Name
    # -------------------------------------------------------------------------

    name: str

    # TMDB commonly supplies this for person Search results. Keeping it
    # nullable makes parsing resilient to incomplete/older payloads.
    original_name: str | None = None

    # -------------------------------------------------------------------------
    # Professional metadata
    # -------------------------------------------------------------------------

    known_for_department: str | None = None

    # Keep the raw numeric TMDB representation at the integration boundary.
    gender: int | None = None

    # -------------------------------------------------------------------------
    # Artwork
    # -------------------------------------------------------------------------

    profile_path: str | None = None

    # -------------------------------------------------------------------------
    # Known-for titles
    # -------------------------------------------------------------------------

    known_for: list[_TmdbKnownForResult] = Field(
        default_factory=list,
    )

    # -------------------------------------------------------------------------
    # Content flags
    # -------------------------------------------------------------------------

    adult: bool = False

    # -------------------------------------------------------------------------
    # TMDB ranking metadata
    # -------------------------------------------------------------------------

    popularity: float = 0.0


# =============================================================================
# Multi-search result
# =============================================================================


type TmdbMultiSearchResult = Annotated[
    TmdbMovieSearchResult | TmdbTvSearchResult | TmdbPersonSearchResult,
    Field(
        discriminator="media_type",
    ),
]

# =============================================================================
# Generic paginated Search response
# =============================================================================


SearchResultT = TypeVar(
    "SearchResultT",
    bound=BaseModel,
)


class TmdbSearchPage[SearchResultT](
    _TmdbSearchModel,
):
    """Generic raw TMDB paginated Search response.

    Examples
    --------
    Movie Search:

        TmdbSearchPage[TmdbMovieSearchResult]

    TV Search:

        TmdbSearchPage[TmdbTvSearchResult]

    Person Search:

        TmdbSearchPage[TmdbPersonSearchResult]

    Multi Search:

        TmdbSearchPage[TmdbMultiSearchResult]
    """

    page: int = Field(
        ge=0,
    )

    results: list[SearchResultT] = Field(
        default_factory=list,
    )

    total_pages: int = Field(
        ge=0,
    )

    total_results: int = Field(
        ge=0,
    )


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "TmdbMovieSearchResult",
    "TmdbMultiSearchResult",
    "TmdbPersonSearchResult",
    "TmdbSearchPage",
    "TmdbTvSearchResult",
]
