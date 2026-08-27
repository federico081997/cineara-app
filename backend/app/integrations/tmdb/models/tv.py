"""Raw response models for TMDB TV-series detail endpoints.

This module contains the Pydantic transport models used to deserialize the
top-level response returned by:

    GET /tv/{series_id}

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

Raw TMDB TV data must be mapped into Cineara-owned domain or API models before
it leaves the backend integration boundary.

Shared TMDB transport structures such as genres, production companies,
production countries, and spoken languages are defined in ``common.py``.
TV-specific embedded structures remain in this module.

Design principles
-----------------
1. Preserve TMDB's data shape.

   These models describe upstream TMDB data rather than Cineara's public API.

2. Keep artwork as raw TMDB paths.

   Fields such as ``poster_path``, ``backdrop_path``, ``profile_path``,
   ``logo_path``, and ``still_path`` remain relative paths. Final image URLs
   are constructed by ``image_url.py``.

3. Keep dates as strings.

   TMDB may return missing or empty dates for incomplete catalogue records.
   Parsing and presentation belong to higher application layers.

4. Handle optional metadata defensively.

   Missing catalogue metadata should not invalidate an otherwise usable TV
   response.

5. Ignore unknown upstream fields.

   The shared ``TmdbModel`` base ignores additive upstream fields so unrelated
   TMDB response changes do not break Cineara's integration.

6. Keep derived Cineara semantics outside this module.

   Media classification, normalized genres, country interpretation, runtime
   calculations, status interpretation, and display formatting belong in
   mapper, catalogue, or feature layers.

7. Keep top-level TV details independent of subordinate resources.

   Credits, images, videos, content ratings, external IDs, recommendations,
   watch providers, seasons, episodes, and other resource responses do not
   belong in the top-level TV-details transport model.

8. Keep Search independent of TV Details.

   Cineara Search uses TMDB Search response models and does not request TV
   Details for individual Search results.
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
# Creator
# =============================================================================


class TmdbTvCreator(TmdbModel):
    """Creator embedded in a TMDB TV-series detail response.

    Entries are returned through the top-level ``created_by`` collection.

    This is a lightweight embedded TMDB representation rather than a complete
    person or credit resource.
    """

    id: int = Field(
        gt=0,
    )

    name: str

    credit_id: str | None = None

    # TMDB represents gender using an integer value. Interpretation belongs
    # outside the raw transport layer.
    gender: int | None = None

    profile_path: str | None = None


# =============================================================================
# Network
# =============================================================================


class TmdbTvNetwork(TmdbModel):
    """Network embedded in a TMDB TV-series detail response.

    This is a lightweight embedded representation rather than a complete
    network resource.
    """

    id: int = Field(
        gt=0,
    )

    name: str

    logo_path: str | None = None

    # TMDB may use an empty string when no origin country is available.
    origin_country: str = ""


# =============================================================================
# Season summary
# =============================================================================


class TmdbTvSeasonSummary(TmdbModel):
    """Lightweight season summary embedded in TV-series details.

    This model represents entries from the top-level ``seasons`` collection.
    It is distinct from the complete response returned by a season-details
    endpoint.
    """

    id: int = Field(
        gt=0,
    )

    season_number: int = Field(
        ge=0,
    )

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
# Episode summary
# =============================================================================


class TmdbTvEpisodeSummary(TmdbModel):
    """Lightweight episode summary embedded in TV-series details.

    TMDB uses this structure for top-level fields such as:

    - ``last_episode_to_air``;
    - ``next_episode_to_air``.

    It is distinct from a complete episode-details response.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int = Field(
        gt=0,
    )

    # =========================================================================
    # Name and description
    # =========================================================================

    name: str = ""

    overview: str = ""

    # =========================================================================
    # Airing metadata
    # =========================================================================

    air_date: str | None = None

    episode_number: int = Field(
        ge=0,
    )

    season_number: int = Field(
        ge=0,
    )

    # Keep the upstream value unmodified rather than constraining transport
    # validation to a fixed set of TMDB episode-type strings.
    episode_type: str | None = None

    # =========================================================================
    # Runtime
    # =========================================================================

    runtime: int | None = Field(
        default=None,
        ge=0,
    )

    # =========================================================================
    # Artwork
    # =========================================================================

    still_path: str | None = None

    # =========================================================================
    # Production metadata
    # =========================================================================

    production_code: str = ""

    show_id: int | None = Field(
        default=None,
        gt=0,
    )

    # =========================================================================
    # TMDB rating metadata
    # =========================================================================

    vote_average: float = 0.0

    vote_count: int = Field(
        default=0,
        ge=0,
    )


# =============================================================================
# TV-series details
# =============================================================================


class TmdbTvDetails(TmdbModel):
    """Top-level raw response from ``GET /tv/{series_id}``.

    The model contains only metadata returned directly by TMDB's TV Series
    Details endpoint.

    It does not perform:

    - media classification;
    - image URL construction;
    - date parsing;
    - runtime calculations;
    - persistence;
    - caching;
    - additional TMDB requests.

    Fields whose upstream vocabulary may evolve, such as ``type`` and
    ``status``, remain raw strings instead of restrictive application enums.

    Search must use TMDB Search response models rather than requesting TV
    details for individual Search results.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int = Field(
        gt=0,
    )

    # =========================================================================
    # Names
    # =========================================================================

    name: str

    original_name: str

    # =========================================================================
    # Language and origin
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
    # Structural metadata
    # =========================================================================

    # Keep TMDB's raw structural type rather than converting it into a Cineara
    # classification inside the transport layer.
    type: str | None = None

    # Keep TMDB's raw status string for the same reason.
    status: str | None = None

    in_production: bool | None = None

    # =========================================================================
    # Air dates
    # =========================================================================

    first_air_date: str | None = None

    last_air_date: str | None = None

    # =========================================================================
    # Episode and season counts
    # =========================================================================

    number_of_episodes: int | None = Field(
        default=None,
        ge=0,
    )

    number_of_seasons: int | None = Field(
        default=None,
        ge=0,
    )

    # TMDB exposes zero or more typical episode runtimes in minutes.
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
    # Creators
    # =========================================================================

    created_by: list[TmdbTvCreator] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Networks
    # =========================================================================

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
    # TMDB ranking / rating metadata
    # =========================================================================

    popularity: float = 0.0

    vote_average: float = 0.0

    vote_count: int = Field(
        default=0,
        ge=0,
    )
