"""TMDB TV endpoint client.

This module provides resource-specific operations for TMDB TV APIs.

Supported endpoints
-------------------
- ``GET /tv/{series_id}``

The endpoint class is deliberately thin. It owns:

- TMDB TV endpoint paths;
- TV-series identifier validation;
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

from ..models.tv import TmdbTvDetails
from ..request import (
    TmdbQueryParams,
    TmdbRequestClient,
)

# =============================================================================
# Endpoint paths
# =============================================================================


_TV_PATH_PREFIX: Final = "/tv"


# =============================================================================
# TV endpoints
# =============================================================================


class TmdbTvEndpoints:
    """Resource group for TMDB TV endpoints.

    Parameters
    ----------
    request:
        Shared TMDB request client responsible for HTTP transport,
        authentication, response validation, and client lifecycle.

    Notes
    -----
    TV operations return raw TMDB transport models. They do not perform
    Cineara classification, persistence, caching, or Search-specific
    enrichment.
    """

    __slots__ = ("_request",)

    def __init__(
        self,
        request: TmdbRequestClient,
    ) -> None:
        """Create the TV endpoint group."""

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
        series_id: int,
        *,
        language: str | None = None,
    ) -> TmdbTvDetails:
        """Return raw TMDB details for one TV series.

        Parameters
        ----------
        series_id:
            Positive TMDB TV-series identifier.

        language:
            Optional TMDB response language. When omitted, the request
            client's configured default language is used.

        Returns
        -------
        TmdbTvDetails
            Raw response from ``GET /tv/{series_id}``.
        """

        normalized_series_id = _normalize_series_id(
            series_id,
        )

        return await self._request.get_model(
            path=f"{_TV_PATH_PREFIX}/{normalized_series_id}",
            model=TmdbTvDetails,
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
        """Build common TMDB TV query parameters."""

        return {
            "language": self._request.resolve_language(
                language,
            ),
        }


# =============================================================================
# TV-series ID validation
# =============================================================================


def _normalize_series_id(
    value: int,
) -> int:
    """Validate a TMDB TV-series identifier."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError("series_id must be an integer.")

    if value <= 0:
        raise ValueError("series_id must be greater than 0.")

    return value
