"""TMDB Movie endpoint client.

This module provides resource-specific operations for TMDB Movie APIs.

Supported endpoints
-------------------
- ``GET /movie/{movie_id}``

The endpoint class is deliberately thin. It owns:

- TMDB Movie endpoint paths;
- movie-identifier validation;
- endpoint-specific query parameters;
- selection of the correct raw response model.

It does not own:

- HTTP transport behavior;
- retries;
- caching;
- Cineara domain or API models;
- media classification;
- image URL construction;
- persistence;
- user-library state;
- Search enrichment;
- application-level orchestration.

All HTTP behavior is delegated to ``TmdbRequestClient``. Responses are
deserialized into raw TMDB transport models and mapped into Cineara-owned
models outside this integration layer.
"""

from __future__ import annotations

from typing import Final

from ..models.movie import TmdbMovieDetails
from ..request import (
    TmdbQueryParams,
    TmdbRequestClient,
)

# =============================================================================
# Endpoint paths
# =============================================================================


_MOVIE_PATH_PREFIX: Final = "/movie"


# =============================================================================
# Movie endpoints
# =============================================================================


class TmdbMovieEndpoints:
    """Resource group for TMDB Movie endpoints.

    Parameters
    ----------
    request:
        Shared TMDB request client responsible for HTTP transport,
        authentication, response validation, and client lifecycle.

    Notes
    -----
    Movie operations return raw TMDB transport models. They do not perform
    Cineara classification, persistence, caching, or Search-specific
    enrichment.
    """

    __slots__ = ("_request",)

    def __init__(
        self,
        request: TmdbRequestClient,
    ) -> None:
        """Create the Movie endpoint group."""

        if not isinstance(
            request,
            TmdbRequestClient,
        ):
            raise TypeError("request must be a TmdbRequestClient.")

        self._request = request

    # =========================================================================
    # Details
    # =========================================================================

    async def details(
        self,
        movie_id: int,
        *,
        language: str | None = None,
    ) -> TmdbMovieDetails:
        """Return raw TMDB details for one Movie.

        Parameters
        ----------
        movie_id:
            Positive TMDB Movie identifier.

        language:
            Optional TMDB response language. When omitted, the request
            client's configured default language is used.

        Returns
        -------
        TmdbMovieDetails
            Raw response from ``GET /movie/{movie_id}``.
        """

        normalized_movie_id = _normalize_movie_id(
            movie_id,
        )

        return await self._request.get_model(
            path=f"{_MOVIE_PATH_PREFIX}/{normalized_movie_id}",
            model=TmdbMovieDetails,
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
        """Build common TMDB Movie query parameters."""

        return {
            "language": self._request.resolve_language(
                language,
            ),
        }


# =============================================================================
# Movie-ID validation
# =============================================================================


def _normalize_movie_id(
    value: int,
) -> int:
    """Validate a TMDB Movie identifier."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError("movie_id must be an integer.")

    if value <= 0:
        raise ValueError("movie_id must be greater than 0.")

    return value
