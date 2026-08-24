"""Raw TMDB movie-detail models.

These models represent data received directly from:

    GET /movie/{movie_id}

They belong exclusively to the TMDB integration layer and must never be
returned directly to Cineara clients.

Search enrichment
-----------------
Cineara may selectively request movie details when Search metadata is
insufficient for a high-confidence classification.

For example:

    Animation
    + original_language == "ja"
    + missing production-country metadata

may trigger one cached movie-details request so Cineara can determine whether
the title is Anime.

Movie details are cached as reusable core metadata and may later be reused by
the movie-detail page rather than fetched again.
"""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field

# =============================================================================
# Base model
# =============================================================================


class _TmdbMovieModel(BaseModel):
    """Base configuration shared by raw TMDB movie models."""

    model_config = ConfigDict(
        extra="ignore",
    )


# =============================================================================
# Genre
# =============================================================================


class TmdbGenre(_TmdbMovieModel):
    """Raw TMDB genre object.

    Example:

        {
            "id": 18,
            "name": "Drama"
        }
    """

    id: int
    name: str


# =============================================================================
# Production country
# =============================================================================


class TmdbProductionCountry(_TmdbMovieModel):
    """Raw TMDB production-country object.

    Example:

        {
            "iso_3166_1": "JP",
            "name": "Japan"
        }

    This is especially important for Cineara Search because movie Search
    results do not provide the same production-country detail as the movie
    details endpoint.
    """

    iso_3166_1: str
    name: str


# =============================================================================
# Production company
# =============================================================================


class TmdbProductionCompany(_TmdbMovieModel):
    """Raw TMDB production-company object."""

    id: int
    name: str

    logo_path: str | None = None

    origin_country: str = ""


# =============================================================================
# Spoken language
# =============================================================================


class TmdbSpokenLanguage(_TmdbMovieModel):
    """Raw TMDB spoken-language object."""

    iso_639_1: str

    english_name: str = ""
    name: str = ""


# =============================================================================
# Collection summary
# =============================================================================


class TmdbMovieCollectionSummary(_TmdbMovieModel):
    """Raw collection summary embedded in movie details.

    This represents the lightweight ``belongs_to_collection`` object returned
    by TMDB movie details.

    Full collection information belongs to the dedicated TMDB collection
    endpoint/model rather than this object.
    """

    id: int
    name: str

    poster_path: str | None = None
    backdrop_path: str | None = None


# =============================================================================
# Movie details
# =============================================================================


class TmdbMovieDetails(_TmdbMovieModel):
    """Raw response from ``GET /movie/{movie_id}``.

    Required by Search enrichment
    -----------------------------

    Search currently depends on at least:

        id
        production_countries
        original_language
        genres
        runtime
        status

    The remaining top-level fields are retained because this is the canonical
    Cineara representation of the TMDB movie-details response and will later
    be reused by movie-detail mapping.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int

    # =========================================================================
    # Titles
    # =========================================================================

    title: str
    original_title: str

    # =========================================================================
    # Language
    # =========================================================================

    original_language: str | None = None

    # =========================================================================
    # Description
    # =========================================================================

    overview: str | None = None
    tagline: str | None = None

    # =========================================================================
    # Artwork
    # =========================================================================
    #
    # These remain raw TMDB paths.
    #
    # Do not build final URLs inside this model.
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
    # Runtime is expressed by TMDB in minutes.
    #
    # It may be unavailable for incomplete/upcoming catalogue entries.
    # =========================================================================

    runtime: int | None = Field(
        default=None,
        ge=0,
    )

    # =========================================================================
    # Production countries
    # =========================================================================
    #
    # Search enrichment primarily exists to obtain this field.
    #
    # Example:
    #
    #     [
    #         TmdbProductionCountry(
    #             iso_3166_1="JP",
    #             name="Japan",
    #         )
    #     ]
    #
    # Search will later map this to:
    #
    #     country_codes = ["JP"]
    # =========================================================================

    production_countries: list[TmdbProductionCountry] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Production companies
    # =========================================================================

    production_companies: list[TmdbProductionCompany] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Spoken languages
    # =========================================================================

    spoken_languages: list[TmdbSpokenLanguage] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Collection
    # =========================================================================

    belongs_to_collection: TmdbMovieCollectionSummary | None = None

    # =========================================================================
    # Financial metadata
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

    # =========================================================================
    # Convenience helpers
    # =========================================================================

    @property
    def production_country_codes(self) -> list[str]:
        """Return normalized production-country codes.

        This is a convenience for Cineara integration/mapping code.

        Example
        -------

        Raw TMDB:

            production_countries = [
                {
                    "iso_3166_1": "JP",
                    "name": "Japan",
                }
            ]

        Result:

            ["JP"]

        Invalid/blank codes are ignored and duplicates are removed while
        preserving their original order.
        """

        result: list[str] = []
        seen: set[str] = set()

        for country in self.production_countries:
            code = country.iso_3166_1.strip().upper()

            if len(code) != 2:
                continue

            if code in seen:
                continue

            seen.add(code)
            result.append(code)

        return result

    @property
    def genre_ids(self) -> list[int]:
        """Return TMDB genre IDs from the richer detail genre objects.

        Search responses contain:

            genre_ids = [16, 18]

        while movie details contain:

            genres = [
                {"id": 16, "name": "Animation"},
                {"id": 18, "name": "Drama"},
            ]

        This helper makes it straightforward to feed either representation
        into Cineara's ``media_classification.py``.
        """

        return [genre.id for genre in self.genres]

    @property
    def genre_names(self) -> list[str]:
        """Return genre names from the TMDB detail genre objects."""

        return [genre.name for genre in self.genres if genre.name.strip()]


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "TmdbGenre",
    "TmdbMovieCollectionSummary",
    "TmdbMovieDetails",
    "TmdbProductionCompany",
    "TmdbProductionCountry",
    "TmdbSpokenLanguage",
]
