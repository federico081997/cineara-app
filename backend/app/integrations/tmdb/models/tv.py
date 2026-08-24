"""Raw TMDB television-detail models.

These models represent data received directly from:

    GET /tv/{series_id}

They belong exclusively to the TMDB integration layer.

They must NOT be returned directly to the Cineara Flutter application. Cineara
modules should map them into Cineara-owned models before exposing them through
the public API.

Search enrichment
-----------------
Cineara may selectively request TV details when Search metadata is not rich
enough to resolve an important classification question.

Typical example:

    /search/tv
        ↓
    JP + Drama
        ↓
    tv_type unavailable
        ↓
    cached TV-details lookup
        ↓
    GET /tv/{series_id} only on cache miss
        ↓
    TmdbTvDetails.type == "Miniseries"
        ↓
    classify_tv(...)
        ↓
    media_format = miniseries
    special_classification = j_drama

The full top-level detail response is useful beyond Search classification, so
it should be cached and reused by the later TV-series detail page rather than
discarded after enrichment.

Design principles
-----------------

1. These are raw TMDB models.

   Image fields remain paths such as:

       /abcdef.jpg

   Final URLs are created by ``image_url.py``.

2. Dates remain strings.

   Missing or incomplete upstream dates should not make the complete payload
   fail validation unnecessarily.

3. Unknown TMDB fields are ignored.

4. Optional metadata is handled defensively.

5. Classification semantics remain outside this module.

   This module exposes factual metadata such as:

       genres
       origin_country
       original_language
       type

   ``media_classification.py`` decides what those facts mean.

6. Movie and TV IDs remain separate resource namespaces.

   A TV entity must be fetched from:

       /tv/{series_id}

   never from:

       /movie/{id}
"""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field

from .movie import (
    TmdbGenre,
    TmdbProductionCompany,
    TmdbProductionCountry,
    TmdbSpokenLanguage,
)

# =============================================================================
# Base model
# =============================================================================


class _TmdbTvModel(BaseModel):
    """Base configuration shared by raw TMDB TV-detail models."""

    model_config = ConfigDict(
        extra="ignore",
    )


# =============================================================================
# Creator
# =============================================================================


class TmdbTvCreator(_TmdbTvModel):
    """Raw TMDB ``created_by`` entry."""

    id: int
    name: str

    credit_id: str | None = None
    gender: int | None = None
    profile_path: str | None = None


# =============================================================================
# Network
# =============================================================================


class TmdbTvNetwork(_TmdbTvModel):
    """Raw TMDB network object."""

    id: int
    name: str

    logo_path: str | None = None
    origin_country: str = ""


# =============================================================================
# Season summary
# =============================================================================


class TmdbTvSeasonSummary(_TmdbTvModel):
    """Lightweight season object embedded in TV-series details."""

    id: int
    season_number: int

    name: str = ""
    overview: str = ""

    air_date: str | None = None
    poster_path: str | None = None

    episode_count: int = Field(
        default=0,
        ge=0,
    )

    vote_average: float = 0.0


# =============================================================================
# Embedded episode summary
# =============================================================================


class TmdbTvEpisodeSummary(_TmdbTvModel):
    """Episode summary for last/next aired episode."""

    id: int

    name: str = ""
    overview: str = ""

    air_date: str | None = None

    episode_number: int = Field(
        ge=0,
    )
    season_number: int = Field(
        ge=0,
    )

    episode_type: str | None = None

    runtime: int | None = Field(
        default=None,
        ge=0,
    )

    still_path: str | None = None

    vote_average: float = 0.0
    vote_count: int = Field(
        default=0,
        ge=0,
    )

    production_code: str = ""
    show_id: int | None = None


# =============================================================================
# TV details
# =============================================================================


class TmdbTvDetails(_TmdbTvModel):
    """Raw response from ``GET /tv/{series_id}``.

    Fields most important to Search enrichment
    ------------------------------------------
    Cineara's selective Search enrichment primarily depends on:

        id
        genres
        origin_country
        original_language
        type

    These facts allow ``media_classification.py`` to determine, when supported:

        Series vs Miniseries
        Anime
        K-Drama
        C-Drama
        J-Drama
        Taiwanese Drama
        Hong Kong Drama
        Thai Drama
        Indian Drama
        Pakistani Drama
        Turkish Drama
        Documentary
        Reality
        Talk Show
        News

    The remaining top-level fields are retained because this model is reusable
    by Cineara's TV-series detail mapping/cache layer.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int

    # =========================================================================
    # Names
    # =========================================================================

    name: str
    original_name: str

    # =========================================================================
    # Language/origin
    # =========================================================================

    original_language: str | None = None

    origin_country: list[str] = Field(
        default_factory=list,
    )

    languages: list[str] = Field(
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

    poster_path: str | None = None
    backdrop_path: str | None = None

    # =========================================================================
    # Genres
    # =========================================================================

    genres: list[TmdbGenre] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Structural/status metadata
    # =========================================================================

    type: str | None = None
    status: str | None = None

    in_production: bool | None = None

    # =========================================================================
    # Dates
    # =========================================================================

    first_air_date: str | None = None
    last_air_date: str | None = None

    # =========================================================================
    # Episode/season counts
    # =========================================================================

    number_of_episodes: int | None = Field(
        default=None,
        ge=0,
    )

    number_of_seasons: int | None = Field(
        default=None,
        ge=0,
    )

    episode_run_time: list[int] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Embedded episode metadata
    # =========================================================================

    last_episode_to_air: TmdbTvEpisodeSummary | None = None
    next_episode_to_air: TmdbTvEpisodeSummary | None = None

    # =========================================================================
    # Seasons
    # =========================================================================

    seasons: list[TmdbTvSeasonSummary] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Creators/networks
    # =========================================================================

    created_by: list[TmdbTvCreator] = Field(
        default_factory=list,
    )

    networks: list[TmdbTvNetwork] = Field(
        default_factory=list,
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
    # External metadata
    # =========================================================================

    homepage: str | None = None

    # =========================================================================
    # Content flags
    # =========================================================================

    adult: bool = False

    # =========================================================================
    # TMDB ranking/rating metadata
    # =========================================================================

    popularity: float = 0.0

    vote_average: float = 0.0

    vote_count: int = Field(
        default=0,
        ge=0,
    )

    # =========================================================================
    # Convenience helpers
    # =========================================================================

    @property
    def tv_type(self) -> str | None:
        """Return the raw TMDB TV-detail ``type`` value.

        This alias makes call sites clearer:

            classify_tv(
                ...,
                tv_type=details.tv_type,
            )
        """

        return self.type

    @property
    def genre_ids(self) -> list[int]:
        """Return TMDB genre IDs from detail genre objects."""

        return [genre.id for genre in self.genres]

    @property
    def genre_names(self) -> list[str]:
        """Return non-blank genre names from detail genre objects."""

        return [genre.name for genre in self.genres if genre.name.strip()]

    @property
    def origin_country_codes(self) -> list[str]:
        """Return normalized TV origin-country codes.

        Invalid/blank values are ignored and duplicates are removed while
        preserving upstream order.
        """

        result: list[str] = []
        seen: set[str] = set()

        for raw_code in self.origin_country:
            code = raw_code.strip().upper()

            if len(code) != 2 or not code.isalpha() or code in seen:
                continue

            seen.add(code)
            result.append(code)

        return result

    @property
    def production_country_codes(self) -> list[str]:
        """Return production-country codes from richer detail data."""

        result: list[str] = []
        seen: set[str] = set()

        for country in self.production_countries:
            code = country.iso_3166_1.strip().upper()

            if len(code) != 2 or not code.isalpha() or code in seen:
                continue

            seen.add(code)
            result.append(code)

        return result


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "TmdbTvCreator",
    "TmdbTvDetails",
    "TmdbTvEpisodeSummary",
    "TmdbTvNetwork",
    "TmdbTvSeasonSummary",
]
