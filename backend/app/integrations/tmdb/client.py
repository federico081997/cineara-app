"""High-level TMDB integration client.

This module exposes Cineara's public TMDB integration facade.

``TmdbClient`` composes:

- one shared ``TmdbRequestClient``;
- TMDB Search endpoints;
- TMDB Trending endpoints;
- TMDB Movie endpoints;
- TMDB TV endpoints.

The facade intentionally keeps endpoint-specific logic inside the corresponding
``endpoints`` modules. It is responsible only for:

- constructing the shared request transport;
- constructing resource endpoint groups;
- exposing those groups through stable properties;
- delegating common client configuration;
- managing the shared HTTP-client lifecycle.

It does not own:

- endpoint paths;
- query-parameter validation;
- HTTP request implementation;
- retries;
- caching;
- Cineara domain models;
- media classification;
- persistence;
- Search orchestration;
- image URL construction;
- user-library state.

The client is designed to be created once for the application lifetime and
closed during application shutdown.
"""

from __future__ import annotations

from types import TracebackType

import httpx
from pydantic import SecretStr

from .endpoints.movies import TmdbMovieEndpoints
from .endpoints.search import TmdbSearchEndpoints
from .endpoints.trending import TmdbTrendingEndpoints
from .endpoints.tv import TmdbTvEndpoints
from .request import TmdbRequestClient

# =============================================================================
# TMDB client
# =============================================================================


class TmdbClient:
    """Facade for Cineara's TMDB integration.

    Parameters
    ----------
    access_token:
        TMDB API Read Access Token used for Bearer authentication.

    base_url:
        TMDB API base URL.

        Runtime configuration belongs to Cineara's application settings and is
        therefore supplied explicitly when the client is constructed.

    language:
        Default TMDB localization language.

        Endpoint methods may override this value for individual requests.

    timeout_seconds:
        Maximum duration allowed for an individual TMDB request.

    http_client:
        Optional externally managed ``httpx.AsyncClient``.

        When omitted, ``TmdbRequestClient`` creates and owns its HTTP client.

        When supplied, lifecycle ownership remains with the caller and the
        client is not closed by ``TmdbClient``.

    Notes
    -----
    The facade exposes endpoint groups rather than duplicating their methods.

    One instance should normally exist for the FastAPI application lifetime.

    Examples
    --------
    Search Movies::

        await tmdb.search.movies(
            query="Dune",
            page=1,
        )

    Fetch Movie Details::

        await tmdb.movies.details(
            movie_id=438631,
        )

    Fetch Trending Content::

        await tmdb.trending.all(
            time_window="week",
        )
    """

    __slots__ = (
        "_movies",
        "_request",
        "_search",
        "_trending",
        "_tv",
    )

    def __init__(
        self,
        *,
        access_token: str | SecretStr,
        base_url: str,
        language: str,
        timeout_seconds: float,
        http_client: httpx.AsyncClient | None = None,
    ) -> None:
        """Create the TMDB facade and its endpoint groups."""

        request = TmdbRequestClient(
            access_token=access_token,
            base_url=base_url,
            language=language,
            timeout_seconds=timeout_seconds,
            http_client=http_client,
        )

        self._request = request

        self._search = TmdbSearchEndpoints(
            request,
        )

        self._trending = TmdbTrendingEndpoints(
            request,
        )

        self._movies = TmdbMovieEndpoints(
            request,
        )

        self._tv = TmdbTvEndpoints(
            request,
        )

    # =========================================================================
    # Endpoint groups
    # =========================================================================

    @property
    def search(self) -> TmdbSearchEndpoints:
        """Return the TMDB Search endpoint group."""

        return self._search

    @property
    def trending(self) -> TmdbTrendingEndpoints:
        """Return the TMDB Trending endpoint group."""

        return self._trending

    @property
    def movies(self) -> TmdbMovieEndpoints:
        """Return the TMDB Movie endpoint group."""

        return self._movies

    @property
    def tv(self) -> TmdbTvEndpoints:
        """Return the TMDB TV endpoint group."""

        return self._tv

    # =========================================================================
    # Shared configuration
    # =========================================================================

    @property
    def base_url(self) -> str:
        """Return the normalized TMDB API base URL."""

        return self._request.base_url

    @property
    def language(self) -> str:
        """Return the configured default TMDB localization language."""

        return self._request.language

    @property
    def timeout_seconds(self) -> float:
        """Return the configured per-request timeout in seconds."""

        return self._request.timeout_seconds

    # =========================================================================
    # Lifecycle state
    # =========================================================================

    @property
    def is_closed(self) -> bool:
        """Return whether the underlying TMDB request client is closed."""

        return self._request.is_closed

    # =========================================================================
    # Lifecycle management
    # =========================================================================

    async def aclose(self) -> None:
        """Close resources owned by the underlying request client.

        Calling this method more than once is safe.

        An externally supplied ``httpx.AsyncClient`` remains owned by the
        caller and is not closed by ``TmdbClient``.
        """

        await self._request.aclose()

    async def __aenter__(self) -> TmdbClient:
        """Enter an asynchronous context-manager scope."""

        if self.is_closed:
            raise RuntimeError("Cannot enter a closed TmdbClient context.")

        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Close owned resources when leaving an async context."""

        await self.aclose()
