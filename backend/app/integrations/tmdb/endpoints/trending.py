"""TMDB Trending endpoint client.

This module provides the resource-specific operations for TMDB Trending APIs.

Supported endpoints
-------------------
- ``GET /trending/all/{time_window}``
- ``GET /trending/movie/{time_window}``
- ``GET /trending/tv/{time_window}``
- ``GET /trending/person/{time_window}``

The endpoint class is deliberately thin. It owns:

- TMDB Trending endpoint paths;
- time-window validation;
- endpoint-specific query parameters;
- selection of the correct raw response model.

It does not own:

- HTTP transport behavior;
- retries;
- caching;
- Cineara Search or Discover schemas;
- media classification;
- image URL construction;
- persistence;
- application-level orchestration;
- per-result detail enrichment.

All HTTP behavior is delegated to ``TmdbRequestClient``. Trending responses are
deserialized into raw TMDB transport models and mapped into Cineara-owned
models outside this integration layer.
"""

from __future__ import annotations

from typing import Final, Literal

from ..models.common import TmdbPage
from ..models.search import (
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
# Public types
# =============================================================================


type TmdbTrendingTimeWindow = Literal[
    "day",
    "week",
]

# =============================================================================
# Endpoint paths
# =============================================================================


_TRENDING_ALL_PATH_PREFIX: Final = "/trending/all"
_TRENDING_MOVIE_PATH_PREFIX: Final = "/trending/movie"
_TRENDING_TV_PATH_PREFIX: Final = "/trending/tv"
_TRENDING_PERSON_PATH_PREFIX: Final = "/trending/person"


# =============================================================================
# Trending endpoints
# =============================================================================


class TmdbTrendingEndpoints:
    """Resource group for TMDB Trending endpoints.

    Parameters
    ----------
    request:
        Shared TMDB request client responsible for HTTP transport,
        authentication, response validation, and client lifecycle.

    Notes
    -----
    Trending operations return lightweight TMDB result models. They do not
    perform entity-detail requests or enrich individual results.
    """

    __slots__ = ("_request",)

    def __init__(
        self,
        request: TmdbRequestClient,
    ) -> None:
        """Create the Trending endpoint group."""

        if not isinstance(
            request,
            TmdbRequestClient,
        ):
            raise TypeError("request must be a TmdbRequestClient.")

        self._request = request

    # =========================================================================
    # All
    # =========================================================================

    async def all(
        self,
        *,
        time_window: TmdbTrendingTimeWindow = "week",
        language: str | None = None,
    ) -> TmdbPage[TmdbMultiSearchResult]:
        """Return trending Movies, TV series, and People.

        Parameters
        ----------
        time_window:
            TMDB Trending window. Supported values are ``"day"`` and
            ``"week"``.

        language:
            Optional TMDB response language. When omitted, the request
            client's configured default language is used.
        """

        normalized_time_window = _normalize_time_window(
            time_window,
        )

        return await self._request.get_model(
            path=f"{_TRENDING_ALL_PATH_PREFIX}/{normalized_time_window}",
            model=TmdbPage[TmdbMultiSearchResult],
            params=self._build_params(
                language=language,
            ),
        )

    # =========================================================================
    # Movies
    # =========================================================================

    async def movies(
        self,
        *,
        time_window: TmdbTrendingTimeWindow = "week",
        language: str | None = None,
    ) -> TmdbPage[TmdbMovieSearchResult]:
        """Return trending Movies."""

        normalized_time_window = _normalize_time_window(
            time_window,
        )

        return await self._request.get_model(
            path=f"{_TRENDING_MOVIE_PATH_PREFIX}/{normalized_time_window}",
            model=TmdbPage[TmdbMovieSearchResult],
            params=self._build_params(
                language=language,
            ),
        )

    # =========================================================================
    # TV
    # =========================================================================

    async def tv(
        self,
        *,
        time_window: TmdbTrendingTimeWindow = "week",
        language: str | None = None,
    ) -> TmdbPage[TmdbTvSearchResult]:
        """Return trending TV series."""

        normalized_time_window = _normalize_time_window(
            time_window,
        )

        return await self._request.get_model(
            path=f"{_TRENDING_TV_PATH_PREFIX}/{normalized_time_window}",
            model=TmdbPage[TmdbTvSearchResult],
            params=self._build_params(
                language=language,
            ),
        )

    # =========================================================================
    # People
    # =========================================================================

    async def people(
        self,
        *,
        time_window: TmdbTrendingTimeWindow = "week",
        language: str | None = None,
    ) -> TmdbPage[TmdbPersonSearchResult]:
        """Return trending People."""

        normalized_time_window = _normalize_time_window(
            time_window,
        )

        return await self._request.get_model(
            path=f"{_TRENDING_PERSON_PATH_PREFIX}/{normalized_time_window}",
            model=TmdbPage[TmdbPersonSearchResult],
            params=self._build_params(
                language=language,
            ),
        )

    # =========================================================================
    # Parameter construction
    # =========================================================================

    def _build_params(
        self,
        *,
        language: str | None,
    ) -> TmdbQueryParams:
        """Build common TMDB Trending query parameters."""

        return {
            "language": self._request.resolve_language(
                language,
            ),
        }


# =============================================================================
# Time-window validation
# =============================================================================


def _normalize_time_window(
    value: str,
) -> TmdbTrendingTimeWindow:
    """Normalize and validate a TMDB Trending time window."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("time_window must be a string.")

    normalized = value.strip().lower()

    if normalized == "day":
        return "day"

    if normalized == "week":
        return "week"

    raise ValueError("time_window must be either 'day' or 'week'.")
