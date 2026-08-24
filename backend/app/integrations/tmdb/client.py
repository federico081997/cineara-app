"""Asynchronous TMDB API client used by Cineara.

``TmdbClient`` is Cineara's single direct network boundary for TMDB.

Feature modules such as Search, Discover, Home and Media Details must call this
client rather than constructing TMDB HTTP requests themselves.

Supported Search operations
---------------------------

    All
        -> GET /search/multi

    Movies
        -> GET /search/movie

    TV
        -> GET /search/tv

    People
        -> GET /search/person

Selective detail enrichment
---------------------------

Search may selectively request richer details when the Search payload does not
contain enough information for a high-confidence classification:

    movie
        -> GET /movie/{movie_id}

    tv
        -> GET /tv/{series_id}

The client does NOT decide whether enrichment is necessary and does NOT cache
the response. Higher application layers own those decisions.

Typical flow:

    Search result
        ↓
    classify with Search metadata
        ↓
    classification says enrichment may be useful
        ↓
    cache lookup
        ↓
    cache miss
        ↓
    TmdbClient.get_movie_details(...)
        or
    TmdbClient.get_tv_details(...)
        ↓
    cache details
        ↓
    reclassify

The returned top-level detail model is intentionally reusable by later media
detail pages. If Search already fetched it, higher layers should normally reuse
the cached response instead of immediately requesting the same resource again.

Responsibilities
----------------

This client owns:

- TMDB authentication;
- URL/request construction;
- request-level localization parameters;
- timeout handling;
- transport error handling;
- HTTP status handling;
- JSON decoding;
- raw TMDB Pydantic-model validation.

This client does NOT own:

- Search minimum-query-length policy;
- frontend debounce behavior;
- Search-result caching;
- media-details caching;
- enrichment-selection policy;
- enrichment batching;
- concurrency limits;
- request coalescing/single-flight behavior;
- classification;
- mapping into Cineara/Flutter-facing models;
- user-library state;
- content-policy decisions.

Lifecycle
---------

Create one ``TmdbClient`` for the application lifetime and reuse it.

For example, FastAPI lifespan can construct one instance, store it on
``app.state``, and close it during application shutdown.

Do not create a new ``httpx.AsyncClient`` for every TMDB request.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import Any, TypeVar

import httpx
from pydantic import BaseModel, SecretStr, ValidationError

from .models.movie import TmdbMovieDetails
from .models.search import (
    TmdbMovieSearchResult,
    TmdbMultiSearchResult,
    TmdbPersonSearchResult,
    TmdbSearchPage,
    TmdbTvSearchResult,
)
from .models.tv import TmdbTvDetails

# =============================================================================
# Defaults
# =============================================================================


DEFAULT_TMDB_BASE_URL = "https://api.themoviedb.org/3"
DEFAULT_TMDB_LANGUAGE = "en-US"
DEFAULT_TMDB_TIMEOUT_SECONDS = 10.0

# =============================================================================
# Endpoint paths
# =============================================================================
#
# Static Search paths are centralized here. Dynamic detail paths are built from
# validated identifiers in their respective public methods.
# =============================================================================


_SEARCH_MULTI_PATH = "/search/multi"
_SEARCH_MOVIE_PATH = "/search/movie"
_SEARCH_TV_PATH = "/search/tv"
_SEARCH_PERSON_PATH = "/search/person"

# =============================================================================
# Generic model type
# =============================================================================


_ModelT = TypeVar(
    "_ModelT",
    bound=BaseModel,
)


# =============================================================================
# TMDB client exceptions
# =============================================================================


class TmdbClientError(Exception):
    """Base exception for failures originating from ``TmdbClient``."""


class TmdbRequestError(TmdbClientError):
    """Raised when a request cannot successfully reach TMDB."""


class TmdbTimeoutError(TmdbRequestError):
    """Raised when a request to TMDB exceeds its configured timeout."""


class TmdbHttpError(TmdbClientError):
    """Raised when TMDB returns a non-successful HTTP response."""

    def __init__(
        self,
        *,
        status_code: int,
        message: str,
        retry_after_seconds: int | None = None,
    ) -> None:
        """Initialize a TMDB HTTP error.

        ``retry_after_seconds`` is populated when TMDB returns a usable
        ``Retry-After`` header, most notably for HTTP 429 responses. The client
        deliberately does not retry automatically because retry/concurrency
        policy belongs to the orchestration layer.
        """

        self.status_code = status_code
        self.message = message
        self.retry_after_seconds = retry_after_seconds

        suffix = (
            f" Retry after {retry_after_seconds} seconds."
            if retry_after_seconds is not None
            else ""
        )

        super().__init__(
            f"TMDB request failed with HTTP {status_code}: {message}.{suffix}"
        )


class TmdbResponseError(TmdbClientError):
    """Raised when a successful TMDB response cannot be parsed."""


# =============================================================================
# Client
# =============================================================================


class TmdbClient:
    """Asynchronous client for TMDB's API.

    Parameters
    ----------
    access_token:
        TMDB API Read Access Token.

        ``str`` and Pydantic ``SecretStr`` are accepted so application
        configuration can pass the token without exposing it.

    base_url:
        TMDB API base URL.

    language:
        Default TMDB localization language.

        Individual requests may override this.

    timeout_seconds:
        Maximum duration allowed for each TMDB request.

    http_client:
        Optional externally managed ``httpx.AsyncClient``.

        When supplied, ``TmdbClient`` does not close it. When omitted,
        ``TmdbClient`` creates and owns one reusable client.
    """

    def __init__(
        self,
        *,
        access_token: str | SecretStr,
        base_url: str = DEFAULT_TMDB_BASE_URL,
        language: str = DEFAULT_TMDB_LANGUAGE,
        timeout_seconds: float = DEFAULT_TMDB_TIMEOUT_SECONDS,
        http_client: httpx.AsyncClient | None = None,
    ) -> None:
        """Initialize the TMDB client."""

        self._access_token = _normalize_access_token(
            access_token,
        )
        self._base_url = _normalize_base_url(
            base_url,
        )
        self._language = _normalize_language(
            language,
        )
        self._timeout = _build_timeout(
            timeout_seconds,
        )

        if http_client is None:
            self._http_client = httpx.AsyncClient()
            self._owns_http_client = True
        else:
            self._http_client = http_client
            self._owns_http_client = False

        self._closed = False

    # =========================================================================
    # Public properties
    # =========================================================================

    @property
    def base_url(self) -> str:
        """Return the normalized TMDB API base URL."""

        return self._base_url

    @property
    def language(self) -> str:
        """Return the default TMDB language."""

        return self._language

    @property
    def is_closed(self) -> bool:
        """Return whether this client has been closed."""

        return self._closed

    # =========================================================================
    # Search — multi
    # =========================================================================

    async def search_multi(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbSearchPage[TmdbMultiSearchResult]:
        """Search movies, TV shows and people in one TMDB request.

        TMDB endpoint:

            GET /search/multi
        """

        params = self._build_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._get_model(
            path=_SEARCH_MULTI_PATH,
            params=params,
            model=TmdbSearchPage[TmdbMultiSearchResult],
        )

    # =========================================================================
    # Search — movies
    # =========================================================================

    async def search_movies(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbSearchPage[TmdbMovieSearchResult]:
        """Search TMDB movies.

        TMDB endpoint:

            GET /search/movie
        """

        params = self._build_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._get_model(
            path=_SEARCH_MOVIE_PATH,
            params=params,
            model=TmdbSearchPage[TmdbMovieSearchResult],
        )

    # =========================================================================
    # Search — TV
    # =========================================================================

    async def search_tv(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbSearchPage[TmdbTvSearchResult]:
        """Search TMDB television shows.

        TMDB endpoint:

            GET /search/tv

        TV Search already provides useful factual metadata such as:

            origin_country
            original_language
            genre_ids
            first_air_date

        This is sufficient for many Search-time classifications.

        It is deliberately not assumed to be sufficient for:

            Series vs Miniseries
            K-Drama
            C-Drama
            J-Drama
            Taiwanese Drama
            Hong Kong Drama
            Thai Drama
            Indian Drama
            Pakistani Drama
            Turkish Drama

        When the classification/orchestration layer marks a result as worth
        enriching, it should check its cache and then call
        ``get_tv_details()`` only on a cache miss.
        """

        params = self._build_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._get_model(
            path=_SEARCH_TV_PATH,
            params=params,
            model=TmdbSearchPage[TmdbTvSearchResult],
        )

    # =========================================================================
    # Search — people
    # =========================================================================

    async def search_people(
        self,
        query: str,
        *,
        page: int = 1,
        language: str | None = None,
        include_adult: bool = False,
    ) -> TmdbSearchPage[TmdbPersonSearchResult]:
        """Search TMDB people.

        TMDB endpoint:

            GET /search/person
        """

        params = self._build_search_params(
            query=query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        return await self._get_model(
            path=_SEARCH_PERSON_PATH,
            params=params,
            model=TmdbSearchPage[TmdbPersonSearchResult],
        )

    # =========================================================================
    # Movie details
    # =========================================================================

    async def get_movie_details(
        self,
        movie_id: int,
        *,
        language: str | None = None,
    ) -> TmdbMovieDetails:
        """Retrieve top-level TMDB movie details.

        TMDB endpoint:

            GET /movie/{movie_id}

        Cineara may use this for selective Search enrichment when the Search
        result lacks facts required for a high-confidence classification.

        Example:

            Animation
            + original_language == "ja"
            + production-country metadata unavailable

        can justify a cached movie-details lookup so Cineara can determine
        whether the movie is Anime.

        The caller owns cache lookup/storage. This method performs only the
        validated TMDB request.

        Parameters
        ----------
        movie_id:
            Positive TMDB movie identifier.

        language:
            Optional request-level language override.
        """

        normalized_movie_id = _normalize_identifier(
            movie_id,
            field_name="movie_id",
        )

        params: dict[str, str] = {
            "language": self._resolve_language(
                language,
            ),
        }

        return await self._get_model(
            path=f"/movie/{normalized_movie_id}",
            params=params,
            model=TmdbMovieDetails,
        )

    # =========================================================================
    # TV details
    # =========================================================================

    async def get_tv_details(
        self,
        series_id: int,
        *,
        language: str | None = None,
    ) -> TmdbTvDetails:
        """Retrieve top-level TMDB TV-series details.

        TMDB endpoint:

            GET /tv/{series_id}

        Cineara may use this for selective Search enrichment when Search-level
        metadata is insufficient to resolve:

            Series vs Miniseries
            regional scripted-TV classification

        Movie and TV identifiers must remain in separate TMDB namespaces. A TV
        result must therefore always come through this method rather than
        ``get_movie_details()``.

        The caller owns cache lookup/storage. This method performs only the
        validated TMDB request.

        Parameters
        ----------
        series_id:
            Positive TMDB TV-series identifier.

        language:
            Optional request-level language override.
        """

        normalized_series_id = _normalize_identifier(
            series_id,
            field_name="series_id",
        )

        params: dict[str, str] = {
            "language": self._resolve_language(
                language,
            ),
        }

        return await self._get_model(
            path=f"/tv/{normalized_series_id}",
            params=params,
            model=TmdbTvDetails,
        )

    # =========================================================================
    # Search parameter construction
    # =========================================================================

    def _build_search_params(
        self,
        *,
        query: str,
        page: int,
        language: str | None,
        include_adult: bool,
    ) -> dict[str, str | int]:
        """Build common TMDB Search query parameters.

        Search product policy such as a minimum query length deliberately does
        not live in this low-level integration client.
        """

        normalized_query = _normalize_query(
            query,
        )
        normalized_page = _normalize_page(
            page,
        )
        resolved_language = self._resolve_language(
            language,
        )

        return {
            "query": normalized_query,
            "page": normalized_page,
            "language": resolved_language,
            "include_adult": ("true" if include_adult else "false"),
        }

    # =========================================================================
    # Language
    # =========================================================================

    def _resolve_language(
        self,
        language: str | None,
    ) -> str:
        """Resolve a request-level language against the client default."""

        if language is None:
            return self._language

        return _normalize_language(
            language,
        )

    # =========================================================================
    # Generic validated GET
    # =========================================================================

    async def _get_model(
        self,
        *,
        path: str,
        params: Mapping[str, Any] | None,
        model: type[_ModelT],
    ) -> _ModelT:
        """Execute GET and validate the JSON payload into ``model``."""

        self._ensure_open()

        payload = await self._get_json(
            path=path,
            params=params,
        )

        try:
            return model.model_validate(
                payload,
            )

        except ValidationError as exc:
            raise TmdbResponseError(
                "TMDB returned a response that does not match "
                f"{model.__name__}."
            ) from exc

    # =========================================================================
    # Generic JSON GET
    # =========================================================================

    async def _get_json(
        self,
        *,
        path: str,
        params: Mapping[str, Any] | None = None,
    ) -> Any:
        """Execute an authenticated GET request and return decoded JSON."""

        self._ensure_open()

        url = self._build_url(
            path,
        )

        try:
            response = await self._http_client.get(
                url,
                params=params,
                headers=self._request_headers(),
                timeout=self._timeout,
            )

        except httpx.TimeoutException as exc:
            raise TmdbTimeoutError(
                f"TMDB request timed out for {path!r}."
            ) from exc

        except httpx.RequestError as exc:
            raise TmdbRequestError(
                f"Could not complete TMDB request for {path!r}."
            ) from exc

        if not response.is_success:
            raise TmdbHttpError(
                status_code=response.status_code,
                message=_extract_error_message(
                    response,
                ),
                retry_after_seconds=_extract_retry_after_seconds(
                    response,
                ),
            )

        try:
            return response.json()

        except ValueError as exc:
            raise TmdbResponseError(
                f"TMDB returned invalid JSON for {path!r}."
            ) from exc

    # =========================================================================
    # Authentication
    # =========================================================================

    def _request_headers(self) -> dict[str, str]:
        """Return headers required for TMDB API requests."""

        return {
            "Authorization": f"Bearer {self._access_token}",
            "Accept": "application/json",
        }

    # =========================================================================
    # URL construction
    # =========================================================================

    def _build_url(
        self,
        path: str,
    ) -> str:
        """Build a complete TMDB API URL from an endpoint path."""

        normalized_path = path.strip()

        if not normalized_path:
            raise ValueError("TMDB endpoint path must not be blank.")

        if not normalized_path.startswith("/"):
            normalized_path = f"/{normalized_path}"

        return f"{self._base_url}{normalized_path}"

    # =========================================================================
    # Lifecycle
    # =========================================================================

    async def aclose(self) -> None:
        """Close resources owned by this TMDB client."""

        if self._closed:
            return

        self._closed = True

        if self._owns_http_client:
            await self._http_client.aclose()

    async def close(self) -> None:
        """Alias for ``aclose()`` for application-lifespan readability."""

        await self.aclose()

    async def __aenter__(self) -> TmdbClient:
        """Enter an asynchronous context manager."""

        self._ensure_open()

        return self

    async def __aexit__(
        self,
        exc_type: object,
        exc_value: object,
        traceback: object,
    ) -> None:
        """Exit an asynchronous context manager."""

        await self.aclose()

    # =========================================================================
    # Lifecycle validation
    # =========================================================================

    def _ensure_open(self) -> None:
        """Raise when code attempts to use a closed client."""

        if self._closed:
            raise TmdbClientError("TmdbClient has already been closed.")


# =============================================================================
# Access-token normalization
# =============================================================================


def _normalize_access_token(
    value: str | SecretStr,
) -> str:
    """Normalize and validate the TMDB API Read Access Token."""

    if isinstance(
        value,
        SecretStr,
    ):
        token = value.get_secret_value()

    elif isinstance(
        value,
        str,
    ):
        token = value

    else:
        raise TypeError("TMDB access token must be a string or SecretStr.")

    normalized = token.strip()

    if not normalized:
        raise ValueError("TMDB access token must not be blank.")

    return normalized


# =============================================================================
# Base-URL normalization
# =============================================================================


def _normalize_base_url(
    value: str,
) -> str:
    """Normalize and validate the TMDB API base URL."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("TMDB base URL must be a string.")

    normalized = value.strip().rstrip("/")

    if not normalized:
        raise ValueError("TMDB base URL must not be blank.")

    if not normalized.lower().startswith("https://"):
        raise ValueError("TMDB base URL must use HTTPS.")

    return normalized


# =============================================================================
# Query normalization
# =============================================================================


def _normalize_query(
    value: str,
) -> str:
    """Normalize a TMDB Search query."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("TMDB Search query must be a string.")

    normalized = value.strip()

    if not normalized:
        raise ValueError("TMDB Search query must not be blank.")

    return normalized


# =============================================================================
# Page normalization
# =============================================================================


def _normalize_page(
    value: int,
) -> int:
    """Validate a TMDB pagination value."""

    # bool subclasses int in Python.
    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError("TMDB page must be an integer.")

    if value < 1:
        raise ValueError("TMDB page must be at least 1.")

    return value


# =============================================================================
# Identifier normalization
# =============================================================================


def _normalize_identifier(
    value: int,
    *,
    field_name: str,
) -> int:
    """Validate a positive TMDB numeric identifier."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError(f"{field_name} must be an integer.")

    if value <= 0:
        raise ValueError(f"{field_name} must be greater than 0.")

    return value


# =============================================================================
# Language normalization
# =============================================================================


def _normalize_language(
    value: str,
) -> str:
    """Normalize a TMDB language value."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("TMDB language must be a string.")

    normalized = value.strip().replace(
        "_",
        "-",
    )

    if not normalized:
        raise ValueError("TMDB language must not be blank.")

    return normalized


# =============================================================================
# Timeout construction
# =============================================================================


def _build_timeout(
    seconds: float,
) -> httpx.Timeout:
    """Build the HTTPX timeout used by TMDB requests."""

    if isinstance(
        seconds,
        bool,
    ):
        raise TypeError("TMDB timeout must be a positive number.")

    try:
        normalized = float(
            seconds,
        )

    except (
        TypeError,
        ValueError,
    ) as exc:
        raise TypeError("TMDB timeout must be a positive number.") from exc

    if normalized <= 0:
        raise ValueError("TMDB timeout must be greater than 0.")

    return httpx.Timeout(
        normalized,
    )


# =============================================================================
# TMDB error extraction
# =============================================================================


def _extract_error_message(
    response: httpx.Response,
) -> str:
    """Extract a safe human-readable message from a TMDB error response."""

    try:
        payload = response.json()

    except ValueError:
        payload = None

    if isinstance(
        payload,
        dict,
    ):
        status_message = payload.get(
            "status_message",
        )

        if isinstance(
            status_message,
            str,
        ):
            normalized = status_message.strip()

            if normalized:
                return normalized

    reason = response.reason_phrase.strip()

    if reason:
        return reason

    return "Unknown TMDB error."


def _extract_retry_after_seconds(
    response: httpx.Response,
) -> int | None:
    """Return an integer ``Retry-After`` delay when one is supplied.

    HTTP also permits an HTTP-date here. Cineara deliberately ignores that form
    at this low-level boundary and exposes only the simple integer delay.
    """

    raw_value = response.headers.get("Retry-After")

    if raw_value is None:
        return None

    normalized = raw_value.strip()

    if not normalized.isdigit():
        return None

    value = int(
        normalized,
    )

    if value < 0:
        return None

    return value


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "DEFAULT_TMDB_BASE_URL",
    "DEFAULT_TMDB_LANGUAGE",
    "DEFAULT_TMDB_TIMEOUT_SECONDS",
    "TmdbClient",
    "TmdbClientError",
    "TmdbHttpError",
    "TmdbRequestError",
    "TmdbResponseError",
    "TmdbTimeoutError",
]
