"""Raw response models for TMDB Search endpoints.

This module contains the Pydantic transport models used to deserialize data
returned directly by TMDB Search APIs.

Supported endpoints
-------------------
- ``GET /search/multi``
- ``GET /search/movie``
- ``GET /search/tv``
- ``GET /search/person``
- ``GET /search/collection``
- ``GET /search/company``
- ``GET /search/keyword``

The models in this module represent TMDB's Search payloads rather than
Cineara's public Search API.

They therefore contain only data supplied by TMDB Search responses and must
not contain:

- detail-endpoint metadata;
- Cineara media classifications;
- normalized genre models;
- generated image URLs;
- cache state;
- persistence state;
- presentation labels;
- application-specific result types;
- additional upstream enrichment.

Raw TMDB Search data must be mapped into Cineara-owned Search schemas before it
leaves the backend integration boundary.

Shared TMDB transport infrastructure, including the base ``TmdbModel`` and
generic ``TmdbPage`` envelope, is defined in ``common.py``.
"""

from __future__ import annotations

from typing import Annotated, Literal

from pydantic import Field

from .common import TmdbModel

# =============================================================================
# Movie Search
# =============================================================================


class TmdbMovieSearchResult(TmdbModel):
    """Movie returned by a TMDB Search response.

    Used by:

    - ``GET /search/movie``;
    - movie entries from ``GET /search/multi``;
    - movie entries contained in a person's ``known_for`` collection.

    Dedicated Movie Search results do not require ``media_type`` in their
    payload, while Multi Search and ``known_for`` entries use it as a
    discriminator. Providing the correct TMDB value as a default allows the
    same raw model to represent all of these payload shapes.

    Only Search-level metadata belongs here. Movie-detail metadata such as
    runtime, production countries, production companies, and collection
    details is intentionally excluded.
    """

    # =========================================================================
    # Discriminator
    # =========================================================================

    media_type: Literal["movie"] = "movie"

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
    # Language
    # =========================================================================

    original_language: str | None = None

    # =========================================================================
    # Description
    # =========================================================================

    overview: str = ""

    # =========================================================================
    # Genres
    # =========================================================================
    #
    # These remain raw TMDB genre IDs. Translation into Cineara's canonical
    # MediaGenre values belongs in the catalogue genre registry.
    # =========================================================================

    genre_ids: list[int] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Release metadata
    # =========================================================================

    release_date: str | None = None

    # =========================================================================
    # Artwork
    # =========================================================================

    poster_path: str | None = None

    backdrop_path: str | None = None

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


# =============================================================================
# TV Search
# =============================================================================


class TmdbTvSearchResult(TmdbModel):
    """TV series returned by a TMDB Search response.

    Used by:

    - ``GET /search/tv``;
    - TV entries from ``GET /search/multi``;
    - TV entries contained in a person's ``known_for`` collection.

    TV Search directly provides lightweight origin and language metadata in
    addition to genre IDs. These values remain raw integration data and are
    interpreted only after crossing into Cineara's catalogue or Search mapper
    layer.

    Detail-only metadata such as networks, seasons, episode counts,
    production companies, and the TV Details ``type`` field does not belong
    in this model.
    """

    # =========================================================================
    # Discriminator
    # =========================================================================

    media_type: Literal["tv"] = "tv"

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

    # =========================================================================
    # Description
    # =========================================================================

    overview: str = ""

    # =========================================================================
    # Genres
    # =========================================================================
    #
    # These remain raw TMDB TV genre IDs. Translation into canonical Cineara
    # genres belongs in ``catalogue/genre_registry.py``.
    # =========================================================================

    genre_ids: list[int] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Airing metadata
    # =========================================================================

    first_air_date: str | None = None

    # =========================================================================
    # Artwork
    # =========================================================================

    poster_path: str | None = None

    backdrop_path: str | None = None

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


# =============================================================================
# Known-for result
# =============================================================================


type TmdbKnownForResult = Annotated[
    TmdbMovieSearchResult | TmdbTvSearchResult,
    Field(
        discriminator="media_type",
    ),
]
"""Movie or TV result embedded in a person's ``known_for`` collection.

TMDB includes these lightweight media records directly in Person Search
responses. Retaining the raw entries allows higher layers to use the metadata
without performing additional TMDB requests.

Only Movie and TV Search results are valid members of this union.
"""


# =============================================================================
# Person Search
# =============================================================================


class TmdbPersonSearchResult(TmdbModel):
    """Person returned by a TMDB Search response.

    Used by:

    - ``GET /search/person``;
    - person entries from ``GET /search/multi``.

    The ``known_for`` collection is retained because it is part of the Search
    response itself and therefore does not require additional upstream
    requests.
    """

    # =========================================================================
    # Discriminator
    # =========================================================================

    media_type: Literal["person"] = "person"

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

    original_name: str | None = None

    # =========================================================================
    # Professional metadata
    # =========================================================================

    known_for_department: str | None = None

    # TMDB represents gender using an integer value. Interpretation belongs
    # outside the raw transport layer.
    gender: int | None = None

    # =========================================================================
    # Artwork
    # =========================================================================

    profile_path: str | None = None

    # =========================================================================
    # Known-for media
    # =========================================================================

    known_for: list[TmdbKnownForResult] = Field(
        default_factory=list,
    )

    # =========================================================================
    # Content flags
    # =========================================================================

    adult: bool = False

    # =========================================================================
    # TMDB ranking metadata
    # =========================================================================

    popularity: float = 0.0


# =============================================================================
# Collection Search
# =============================================================================


class TmdbCollectionSearchResult(TmdbModel):
    """Movie collection returned by ``GET /search/collection``.

    This model represents the lightweight collection metadata returned by
    TMDB Search. It is distinct from a complete TMDB collection-details
    response.

    A TMDB collection is a TMDB-specific movie grouping and should not be
    interpreted as a broader application concept inside this transport model.
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

    original_name: str | None = None

    # =========================================================================
    # Language
    # =========================================================================

    original_language: str | None = None

    # =========================================================================
    # Description
    # =========================================================================

    overview: str = ""

    # =========================================================================
    # Artwork
    # =========================================================================

    poster_path: str | None = None

    backdrop_path: str | None = None

    # =========================================================================
    # Content flags
    # =========================================================================

    adult: bool = False


# =============================================================================
# Company Search
# =============================================================================


class TmdbCompanySearchResult(TmdbModel):
    """Production company returned by ``GET /search/company``.

    TMDB Companies and TV Networks are distinct upstream resource types.
    This model represents only TMDB Company Search results.
    """

    # =========================================================================
    # Identity
    # =========================================================================

    id: int = Field(
        gt=0,
    )

    # =========================================================================
    # Name
    # =========================================================================

    name: str

    # =========================================================================
    # Artwork
    # =========================================================================

    logo_path: str | None = None

    # =========================================================================
    # Origin
    # =========================================================================

    # TMDB may use an empty string when no origin country is available.
    origin_country: str = ""


# =============================================================================
# Keyword Search
# =============================================================================


class TmdbKeywordSearchResult(TmdbModel):
    """Keyword returned by ``GET /search/keyword``.

    ``Keyword`` remains the correct TMDB integration concept. Any
    application-facing terminology is defined outside this transport layer.
    """

    id: int = Field(
        gt=0,
    )

    name: str


# =============================================================================
# Multi Search
# =============================================================================


type TmdbMultiSearchResult = Annotated[
    (TmdbMovieSearchResult | TmdbTvSearchResult | TmdbPersonSearchResult),
    Field(
        discriminator="media_type",
    ),
]
"""Result returned by ``GET /search/multi``.

TMDB Multi Search contains three result families:

- Movie;
- TV;
- Person.

Collections, companies, and keywords are not members of the Multi Search
response and are therefore intentionally excluded from this union.
"""
