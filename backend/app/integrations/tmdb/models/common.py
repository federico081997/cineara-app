"""Shared raw models for TMDB API responses.

This module contains transport structures that are reused across multiple TMDB
resource and endpoint modules.

The models belong exclusively to Cineara's TMDB integration layer. They
represent upstream TMDB payloads and must not contain Cineara-specific
classification, presentation, caching, persistence, or user-library behavior.

Only structures that are genuinely shared across TMDB responses belong here.
Resource-specific models remain in their corresponding modules.

Design principles
-----------------
1. Preserve TMDB's upstream data shape.

2. Ignore unknown upstream fields so additive TMDB response changes do not
   break otherwise valid Cineara requests.

3. Keep provider-specific identifiers and raw artwork paths unchanged.

4. Keep application semantics outside the integration layer.

5. Share transport structures only when the same TMDB payload shape appears
   across multiple resources.

6. Provide a reusable generic page envelope for paginated TMDB endpoints.
"""

from __future__ import annotations

from pydantic import BaseModel, ConfigDict, Field

# =============================================================================
# Base model
# =============================================================================


class TmdbModel(BaseModel):
    """Base class for raw TMDB transport models.

    Unknown fields are ignored deliberately because TMDB may add fields to
    existing responses without changing the endpoint contract.
    """

    model_config = ConfigDict(
        extra="ignore",
    )


# =============================================================================
# Common embedded models
# =============================================================================


class TmdbGenre(TmdbModel):
    """Genre embedded in a TMDB resource response."""

    id: int = Field(
        gt=0,
    )

    name: str


class TmdbProductionCountry(TmdbModel):
    """Production country embedded in a TMDB resource response."""

    iso_3166_1: str

    name: str


class TmdbProductionCompany(TmdbModel):
    """Production company embedded in a TMDB resource response.

    This compact embedded structure is distinct from the complete response
    returned by TMDB's dedicated company-details endpoint.
    """

    id: int = Field(
        gt=0,
    )

    name: str

    logo_path: str | None = None

    # TMDB may use an empty string when no origin country is available.
    origin_country: str = ""


class TmdbSpokenLanguage(TmdbModel):
    """Spoken-language entry embedded in a TMDB resource response."""

    english_name: str = ""

    # Kept optional because some upstream records may not provide a usable
    # ISO 639-1 value.
    iso_639_1: str | None = None

    name: str = ""


# =============================================================================
# Pagination
# =============================================================================


class TmdbPage[ResultT](TmdbModel):
    """Generic paginated response returned by TMDB list-style endpoints.

    ``ResultT`` is intentionally unconstrained. TMDB pages may contain either
    one concrete transport model or a discriminated union such as the result
    type returned by ``/search/multi``.
    """

    page: int = Field(
        ge=1,
    )

    results: list[ResultT]

    total_pages: int = Field(
        ge=0,
    )

    total_results: int = Field(
        ge=0,
    )
