"""TMDB Search endpoint client.

This module provides the resource-specific operations for TMDB Search APIs.

Supported endpoints
-------------------
- ``GET /search/multi``
- ``GET /search/movie``
- ``GET /search/tv``
- ``GET /search/person``
- ``GET /search/collection``
- ``GET /search/company``
- ``GET /search/keyword``

The endpoint class is deliberately thin. It owns:

- TMDB Search endpoint paths;
- endpoint-specific query parameters;
- endpoint-level input validation;
- selection of the correct raw response model.

It does not own:

- HTTP transport behavior;
- retries;
- caching;
- Cineara Search schemas;
- media classification;
- image URL construction;
- persistence;
- application-level Search orchestration;
- per-result detail enrichment.

All HTTP behavior is delegated to ``TmdbRequestClient``. Search results are
deserialized into raw TMDB transport models and mapped into Cineara-owned
models outside this integration layer.
"""

from __future__ import annotations

from typing import Final

from ..models.common import TmdbPage
from ..models.search import (
    TmdbCollectionSearchResult,
    TmdbCompanySearchResult,
    TmdbKeywordSearchResult,
    TmdbMovieSearchResult,
    TmdbMultiSearchResult,
    TmdbPersonSearchResult,
    TmdbTvSearchResult,
)
from ..request import (
    TmdbQueryParams,
    TmdbRequestClient,
)

# =============================================================================
# Endpoint paths
# =============================================================================


_SEARCH_MULTI_PATH: Final = "/search/multi"
_SEARCH_MOVIE_PATH: Final = "/search/movie"
_SEARCH_TV_PATH: Final = "/search/tv"
_SEARCH_PERSON_PATH: Final = "/search/person"
_SEARCH_COLLECTION_PATH: Final = "/search/collection"
_SEARCH_COMPANY_PATH: Final = "/search/company"
_SEARCH_KEYWORD_PATH: Final = "/search/keyword"


# =============================================================================
# Search endpoints
# =============================================================================


class TmdbSearchEndpoints:
    """Resource group for TMDB Search endpoints.

    Parameters
    ----------
    request:
        Shared TMDB request client responsible for HTTP transport,
        authentication, response validation, and client lifecycle.

    Notes
    -----
    This class does not perform any per-result follow-up requests. In
    particular, Search operations must not call Movie Details, TV Details, or
    other entity-detail endpoints to enrich returned Search rows.
    """

    __slots__ = ("_request",)

    def __init__(
        self,
        request: TmdbRequestClient,
    ) -> None:
        """Create the Search endpoint group."""

        if not isinstance(
            request,
            TmdbRequestClient,
        ):
            raise TypeError("request must be a TmdbRequestClient.")

        self._request = request

    # =========================================================================
    # Multi Search
    # =========================================================================

    async def multi(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbPage[TmdbMultiSearchResult]:
        """Search Movies, TV series, and People in one TMDB request."""

        params = self._build_localized_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._request.get_model(
            path=_SEARCH_MULTI_PATH,
            model=TmdbPage[TmdbMultiSearchResult],
            params=params,
        )

    # =========================================================================
    # Movie Search
    # =========================================================================

    async def movies(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
        region: str | None = None,
        year: int | None = None,
        primary_release_year: int | None = None,
    ) -> TmdbPage[TmdbMovieSearchResult]:
        """Search TMDB Movies.

        ``region`` influences region-sensitive release metadata returned by
        TMDB. ``year`` and ``primary_release_year`` are passed through as
        independent TMDB Movie Search filters.
        """

        params = dict(
            self._build_localized_search_params(
                query=query,
                page=page,
                language=language,
                include_adult=include_adult,
            )
        )

        normalized_region = _normalize_region(
            region,
        )

        normalized_year = _normalize_optional_year(
            year,
            name="year",
        )

        normalized_primary_release_year = _normalize_optional_year(
            primary_release_year,
            name="primary_release_year",
        )

        if normalized_region is not None:
            params["region"] = normalized_region

        if normalized_year is not None:
            params["year"] = normalized_year

        if normalized_primary_release_year is not None:
            params["primary_release_year"] = normalized_primary_release_year

        return await self._request.get_model(
            path=_SEARCH_MOVIE_PATH,
            model=TmdbPage[TmdbMovieSearchResult],
            params=params,
        )

    # =========================================================================
    # TV Search
    # =========================================================================

    async def tv(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
        year: int | None = None,
        first_air_date_year: int | None = None,
    ) -> TmdbPage[TmdbTvSearchResult]:
        """Search TMDB TV series."""

        params = dict(
            self._build_localized_search_params(
                query=query,
                page=page,
                language=language,
                include_adult=include_adult,
            )
        )

        normalized_year = _normalize_optional_year(
            year,
            name="year",
        )

        normalized_first_air_date_year = _normalize_optional_year(
            first_air_date_year,
            name="first_air_date_year",
        )

        if normalized_year is not None:
            params["year"] = normalized_year

        if normalized_first_air_date_year is not None:
            params["first_air_date_year"] = normalized_first_air_date_year

        return await self._request.get_model(
            path=_SEARCH_TV_PATH,
            model=TmdbPage[TmdbTvSearchResult],
            params=params,
        )

    # =========================================================================
    # Person Search
    # =========================================================================

    async def people(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbPage[TmdbPersonSearchResult]:
        """Search TMDB People."""

        params = self._build_localized_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._request.get_model(
            path=_SEARCH_PERSON_PATH,
            model=TmdbPage[TmdbPersonSearchResult],
            params=params,
        )

    # =========================================================================
    # Collection Search
    # =========================================================================

    async def collections(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
        region: str | None = None,
    ) -> TmdbPage[TmdbCollectionSearchResult]:
        """Search TMDB Movie Collections."""

        params = dict(
            self._build_localized_search_params(
                query=query,
                page=page,
                language=language,
                include_adult=include_adult,
            )
        )

        normalized_region = _normalize_region(
            region,
        )

        if normalized_region is not None:
            params["region"] = normalized_region

        return await self._request.get_model(
            path=_SEARCH_COLLECTION_PATH,
            model=TmdbPage[TmdbCollectionSearchResult],
            params=params,
        )

    # =========================================================================
    # Company Search
    # =========================================================================

    async def companies(
        self,
        query: str,
        *,
        page: int = 1,
    ) -> TmdbPage[TmdbCompanySearchResult]:
        """Search TMDB Companies."""

        params = self._build_basic_search_params(
            query=query,
            page=page,
        )

        return await self._request.get_model(
            path=_SEARCH_COMPANY_PATH,
            model=TmdbPage[TmdbCompanySearchResult],
            params=params,
        )

    # =========================================================================
    # Keyword Search
    # =========================================================================

    async def keywords(
        self,
        query: str,
        *,
        page: int = 1,
    ) -> TmdbPage[TmdbKeywordSearchResult]:
        """Search TMDB Keywords."""

        params = self._build_basic_search_params(
            query=query,
            page=page,
        )

        return await self._request.get_model(
            path=_SEARCH_KEYWORD_PATH,
            model=TmdbPage[TmdbKeywordSearchResult],
            params=params,
        )

    # =========================================================================
    # Parameter construction
    # =========================================================================

    def _build_localized_search_params(
        self,
        *,
        query: str,
        page: int,
        language: str | None,
        include_adult: bool,
    ) -> TmdbQueryParams:
        """Build common parameters for localized TMDB Search endpoints."""

        normalized_include_adult = _normalize_bool(
            include_adult,
            name="include_adult",
        )

        params: dict[
            str,
            str | int | float | bool | None,
        ] = {
            "query": _normalize_query(
                query,
            ),
            "page": _normalize_page(
                page,
            ),
            "include_adult": normalized_include_adult,
            "language": self._request.resolve_language(
                language,
            ),
        }

        return params

    @staticmethod
    def _build_basic_search_params(
        *,
        query: str,
        page: int,
    ) -> TmdbQueryParams:
        """Build parameters for Search endpoints without locale options."""

        return {
            "query": _normalize_query(
                query,
            ),
            "page": _normalize_page(
                page,
            ),
        }


# =============================================================================
# Query validation
# =============================================================================


def _normalize_query(
    value: str,
) -> str:
    """Normalize and validate a TMDB Search query."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("query must be a string.")

    normalized = value.strip()

    if not normalized:
        raise ValueError("query must not be blank.")

    return normalized


# =============================================================================
# Page validation
# =============================================================================


def _normalize_page(
    value: int,
) -> int:
    """Validate a TMDB Search page number."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError("page must be an integer.")

    if value < 1:
        raise ValueError("page must be greater than or equal to 1.")

    return value


# =============================================================================
# Boolean validation
# =============================================================================


def _normalize_bool(
    value: bool,
    *,
    name: str,
) -> bool:
    """Validate a strict Boolean query parameter."""

    if not isinstance(
        value,
        bool,
    ):
        raise TypeError(f"{name} must be a bool.")

    return value


# =============================================================================
# Year validation
# =============================================================================


def _normalize_optional_year(
    value: int | None,
    *,
    name: str,
) -> int | None:
    """Validate an optional four-digit year."""

    if value is None:
        return None

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError(f"{name} must be an integer or None.")

    if not 1000 <= value <= 9999:
        raise ValueError(f"{name} must be between 1000 and 9999.")

    return value


# =============================================================================
# Region validation
# =============================================================================


def _normalize_region(
    value: str | None,
) -> str | None:
    """Normalize an optional ISO 3166-1 alpha-2 region code."""

    if value is None:
        return None

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("region must be a string or None.")

    normalized = value.strip().upper()

    if not normalized:
        return None

    if len(
        normalized,
    ) != 2 or not all("A" <= character <= "Z" for character in normalized):
        raise ValueError("region must be a two-letter ASCII country code.")

    return normalized
