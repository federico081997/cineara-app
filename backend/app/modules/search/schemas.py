"""Public schemas for Cineara Search.

This module defines the provider-independent API contract returned by Cineara's
Search feature.

The schemas intentionally do not expose raw TMDB transport models. TMDB
keywords become Cineara Topics, TMDB companies become Studios, and Movie/TV
results expose normalized Cineara classification and rating data.

This module owns:

- Search categories;
- public Search result types;
- normalized media classification payloads;
- external rating payloads;
- paginated Search responses;
- grouped Search overview responses;
- Search landing responses.

It does not own:

- HTTP requests;
- TMDB models;
- mapping logic;
- caching;
- persistence;
- user-library state;
- presentation widgets.

Personal state such as watched status, favourites, collection membership,
progress, and personal ratings is deliberately absent from these schemas until
that state is supplied by Cineara's user/library layer.
"""

from __future__ import annotations

from enum import StrEnum
from typing import Annotated, Literal

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    model_validator,
)

from app.catalogue import (
    CulturalClassification,
    MediaFormat,
    MediaGenre,
    ProgrammeClassification,
)

# =============================================================================
# Base schema
# =============================================================================


class _SearchSchema(BaseModel):
    """Base configuration shared by Cineara Search API schemas."""

    model_config = ConfigDict(
        extra="forbid",
        frozen=True,
    )


# =============================================================================
# Search categories
# =============================================================================


class SearchCategory(StrEnum):
    """Dedicated paginated Search categories exposed by Cineara."""

    MOVIES = "movies"
    TV = "tv"
    PEOPLE = "people"
    COLLECTIONS = "collections"
    STUDIOS = "studios"
    TOPICS = "topics"


class SearchResultType(StrEnum):
    """Entity families that may appear in Cineara Search responses."""

    MOVIE = "movie"
    TV = "tv"
    PERSON = "person"
    COLLECTION = "collection"
    STUDIO = "studio"
    TOPIC = "topic"


# =============================================================================
# Ratings
# =============================================================================


class ExternalRatingSource(StrEnum):
    """External rating providers represented in Search responses."""

    TMDB = "tmdb"


class ExternalRating(_SearchSchema):
    """One external rating attached to a Search media result."""

    source: ExternalRatingSource

    value: float = Field(
        ge=0,
    )

    scale: float = Field(
        gt=0,
    )

    vote_count: int | None = Field(
        default=None,
        ge=0,
    )

    @model_validator(
        mode="after",
    )
    def _validate_value_within_scale(self) -> ExternalRating:
        """Ensure the rating does not exceed its declared scale."""

        if self.value > self.scale:
            raise ValueError("value must not be greater than scale.")

        return self


# =============================================================================
# Media classification
# =============================================================================


class SearchMediaClassification(_SearchSchema):
    """Provider-independent classification attached to Movie/TV results."""

    media_format: MediaFormat

    genres: tuple[MediaGenre, ...] = ()

    display_genres: tuple[MediaGenre, ...] = ()

    cultural_classification: CulturalClassification | None = None

    programme_classification: ProgrammeClassification | None = None

    country_codes: tuple[str, ...] = ()

    original_language: str | None = None


# =============================================================================
# Media results
# =============================================================================


class _MediaSearchResult(_SearchSchema):
    """Fields shared by Movie and TV Search results."""

    id: int = Field(
        gt=0,
    )

    title: str

    original_title: str | None = None

    image_url: str | None = None

    year: int | None = Field(
        default=None,
        ge=1000,
        le=9999,
    )

    classification: SearchMediaClassification

    external_ratings: tuple[ExternalRating, ...] = ()


class MovieSearchResult(_MediaSearchResult):
    """Cineara Movie Search result."""

    result_type: Literal["movie"] = "movie"


class TvSearchResult(_MediaSearchResult):
    """Cineara TV Search result."""

    result_type: Literal["tv"] = "tv"


# =============================================================================
# Person results
# =============================================================================


class KnownForSearchItem(_SearchSchema):
    """Compact Movie/TV summary embedded in a Person Search result."""

    result_type: Literal[
        "movie",
        "tv",
    ]

    id: int = Field(
        gt=0,
    )

    title: str

    year: int | None = Field(
        default=None,
        ge=1000,
        le=9999,
    )


class PersonSearchResult(_SearchSchema):
    """Cineara Person Search result."""

    result_type: Literal["person"] = "person"

    id: int = Field(
        gt=0,
    )

    name: str

    image_url: str | None = None

    known_for_department: str | None = None

    known_for: tuple[KnownForSearchItem, ...] = ()


# =============================================================================
# Collection results
# =============================================================================


class CollectionSearchResult(_SearchSchema):
    """Cineara representation of a TMDB movie collection Search result."""

    result_type: Literal["collection"] = "collection"

    id: int = Field(
        gt=0,
    )

    name: str

    image_url: str | None = None


# =============================================================================
# Studio results
# =============================================================================


class StudioSearchResult(_SearchSchema):
    """Cineara Studio Search result backed by a TMDB company result."""

    result_type: Literal["studio"] = "studio"

    id: int = Field(
        gt=0,
    )

    name: str

    image_url: str | None = None

    origin_country_code: str | None = None


# =============================================================================
# Topic results
# =============================================================================


class TopicSearchResult(_SearchSchema):
    """Provider-independent Cineara Topic Search result.

    TMDB keywords are mapped into this schema by the current Search
    implementation. The public API intentionally uses ``Topic`` terminology
    rather than exposing TMDB's provider-specific Keyword concept.
    """

    result_type: Literal["topic"] = "topic"

    id: int = Field(
        gt=0,
    )

    name: str


# =============================================================================
# Result unions
# =============================================================================


type MediaSearchResult = Annotated[
    MovieSearchResult | TvSearchResult,
    Field(
        discriminator="result_type",
    ),
]

type TrendingSearchResult = Annotated[
    MovieSearchResult | TvSearchResult | PersonSearchResult,
    Field(
        discriminator="result_type",
    ),
]

type SearchResult = Annotated[
    (
        MovieSearchResult
        | TvSearchResult
        | PersonSearchResult
        | CollectionSearchResult
        | StudioSearchResult
        | TopicSearchResult
    ),
    Field(
        discriminator="result_type",
    ),
]


# =============================================================================
# Paginated Search
# =============================================================================


class SearchPage(_SearchSchema):
    """Paginated result for one dedicated Cineara Search category."""

    query: str

    category: SearchCategory

    page: int = Field(
        ge=1,
    )

    total_pages: int = Field(
        ge=0,
    )

    total_results: int = Field(
        ge=0,
    )

    results: tuple[SearchResult, ...] = ()


# =============================================================================
# Search overview
# =============================================================================


class SearchOverviewSection(_SearchSchema):
    """One grouped section in Cineara's All-results overview."""

    category: SearchCategory

    results: tuple[SearchResult, ...] = ()

    total_results: int | None = Field(
        default=None,
        ge=0,
    )


class SearchOverview(_SearchSchema):
    """Grouped Search response used by Cineara's All category."""

    query: str

    sections: tuple[SearchOverviewSection, ...] = ()


# =============================================================================
# Search landing
# =============================================================================


class SearchLanding(_SearchSchema):
    """Content shown before the user commits a Search query."""

    trending: tuple[TrendingSearchResult, ...] = ()
