"""Shared asynchronous HTTP transport for Cineara's TMDB integration.

``TmdbRequestClient`` is the lowest-level networking component in the TMDB
integration.

Resource-oriented endpoint groups such as Search, Movies, TV, People,
Collections and Discovery use this class to:

- authenticate requests to TMDB;
- construct safe endpoint URLs;
- apply shared request timeouts;
- execute HTTP requests;
- translate transport failures into TMDB integration exceptions;
- translate unsuccessful HTTP responses into structured TMDB errors;
- decode JSON responses;
- validate responses into raw TMDB Pydantic models;
- manage the shared ``httpx.AsyncClient`` lifecycle.

The request client deliberately knows nothing about Cineara feature behavior.

It does NOT own:

- Search query-length policy;
- Search-result caching;
- Search classification;
- genre mapping;
- Search overview composition;
- detail enrichment;
- pagination policy;
- Discover filtering;
- Cineara-facing response models;
- FastAPI error responses;
- retry or backoff policy;
- user-library state;
- content-visibility policy.

Endpoint-specific validation also remains outside this module.
"""

from __future__ import annotations

import math
from collections.abc import Mapping
from types import TracebackType
from typing import TypeVar
from urllib.parse import urlsplit

import httpx
from pydantic import BaseModel, SecretStr, ValidationError

from .exceptions import (
    TmdbClientClosedError,
    TmdbHttpError,
    TmdbRequestError,
    TmdbResponseError,
    TmdbTimeoutError,
)

# =============================================================================
# Query-parameter types
# =============================================================================
#
# Keep TMDB query parameters constrained to simple values supported by HTTPX.
#
# More complex TMDB filters should normally be serialized by the appropriate
# endpoint group before reaching this transport layer.
#
# For example:
#
#     with_genres=[18, 35]
#
# should become the TMDB-compatible string:
#
#     with_genres="18,35"
#
# inside ``endpoints/discovery.py``.
# =============================================================================


type TmdbQueryValue = str | int | float | bool | None

type TmdbQueryParams = Mapping[
    str,
    TmdbQueryValue,
]

# =============================================================================
# Generic response-model type
# =============================================================================


_ModelT = TypeVar(
    "_ModelT",
    bound=BaseModel,
)


# =============================================================================
# Request client
# =============================================================================


class TmdbRequestClient:
    """Reusable asynchronous HTTP transport for TMDB API requests.

    One instance should normally exist for the application lifetime and be
    shared by all TMDB endpoint groups.

    Parameters
    ----------
    access_token:
        TMDB API Read Access Token.

        Both plain ``str`` and Pydantic ``SecretStr`` values are accepted so
        application settings can pass credentials without unnecessarily
        exposing them.

    base_url:
        TMDB API base URL supplied by the application configuration.

    language:
        Default TMDB localization language supplied by the application
        configuration.

        Endpoint methods may override this value per request through
        :meth:`resolve_language`.

    timeout_seconds:
        Maximum duration allowed for an individual TMDB request, supplied by
        the application configuration.

    http_client:
        Optional externally managed ``httpx.AsyncClient``.

        When omitted, this class creates and owns one reusable asynchronous
        client.

        When supplied, the caller retains ownership of the HTTP client and
        ``TmdbRequestClient`` will not close it.

    Notes
    -----
    Do not instantiate this class for every request.

    The intended application structure is:

        FastAPI lifespan
            ↓
        TmdbRequestClient
            ↓
        TmdbClient facade
            ↓
        endpoint groups
            ↓
        Cineara services
    """

    def __init__(
        self,
        *,
        access_token: str | SecretStr,
        base_url: str,
        language: str,
        timeout_seconds: float,
        http_client: httpx.AsyncClient | None = None,
    ) -> None:
        """Initialize the TMDB request transport."""

        self._access_token = _normalize_access_token(
            access_token,
        )

        self._base_url = _normalize_base_url(
            base_url,
        )

        self._language = _normalize_language(
            language,
        )

        self._timeout_seconds = _normalize_timeout_seconds(
            timeout_seconds,
        )

        self._timeout = httpx.Timeout(
            self._timeout_seconds,
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
        """Return the default TMDB localization language."""

        return self._language

    @property
    def timeout_seconds(self) -> float:
        """Return the configured per-request timeout in seconds."""

        return self._timeout_seconds

    @property
    def is_closed(self) -> bool:
        """Return whether this request transport can no longer be used.

        The externally supplied HTTP client may be closed independently of
        this wrapper. Such a client also makes this transport unusable.
        """

        return self._closed or self._http_client.is_closed

    # =========================================================================
    # Language resolution
    # =========================================================================

    def resolve_language(
        self,
        language: str | None,
    ) -> str:
        """Resolve an optional request language against the client default.

        Endpoint groups should use this helper rather than duplicating language
        normalization.

        Examples
        --------
        No request override:

            request.resolve_language(None)

        returns the configured default, for example:

            "en-US"

        Explicit override:

            request.resolve_language("it_IT")

        returns:

            "it-IT"
        """

        if language is None:
            return self._language

        return _normalize_language(
            language,
        )

    # =========================================================================
    # Validated GET request
    # =========================================================================

    async def get_model(
        self,
        *,
        path: str,
        model: type[_ModelT],
        params: TmdbQueryParams | None = None,
    ) -> _ModelT:
        """Execute an authenticated GET request and validate its response.

        This is the primary operation used by TMDB endpoint groups.

        Parameters
        ----------
        path:
            Relative TMDB API endpoint path.

            Examples:
                - /search/movie
                - /movie/603
                - /tv/1399
                - /trending/all/week

            Complete URLs are deliberately rejected. Endpoint implementations
            may only communicate with the TMDB base URL configured for this
            transport.

        model:
            Raw TMDB Pydantic model used to validate the response.

        params:
            Optional TMDB query parameters. Endpoint-specific parameter
            construction belongs to the endpoint group rather than this
            transport.

        Returns
        -------
        _ModelT
            Validated raw TMDB response model.

        Raises
        ------
        TmdbClientClosedError
            If the request transport or its underlying HTTP client has already
            been closed.

        TmdbTimeoutError
            If the request exceeds the configured timeout.

        TmdbRequestError
            If the HTTP request cannot successfully reach TMDB.

        TmdbHttpError
            If TMDB returns a non-successful HTTP status.

        TmdbResponseError
            If TMDB returns invalid JSON or a successful response that does not
            match the expected Pydantic model.
        """

        self._ensure_open()

        normalized_path = _normalize_path(
            path,
        )

        payload = await self._request_json(
            method="GET",
            path=normalized_path,
            params=params,
        )

        try:
            return model.model_validate(
                payload,
            )

        except ValidationError as exc:
            raise TmdbResponseError(
                "TMDB returned a response that does not match "
                "the expected model.",
                path=normalized_path,
                model_name=_model_name(
                    model,
                ),
            ) from exc

    # =========================================================================
    # Shared request execution
    # =========================================================================

    async def _request_json(
        self,
        *,
        method: str,
        path: str,
        params: TmdbQueryParams | None = None,
    ) -> object:
        """Execute one TMDB request and return its decoded JSON payload.

        This private method centralizes request execution so support for
        additional HTTP methods can be added later without duplicating
        transport behavior.

        Cineara currently uses TMDB primarily as a read-only metadata source,
        so public endpoint operations normally call :meth:`get_model`.
        """

        self._ensure_open()

        url = self._build_url(
            path,
        )

        try:
            response = await self._http_client.request(
                method=method,
                url=url,
                params=params,
                headers=self._request_headers(),
                timeout=self._timeout,
            )

        except httpx.TimeoutException as exc:
            raise TmdbTimeoutError(
                "TMDB request timed out.",
                path=path,
                timeout_seconds=self._timeout_seconds,
            ) from exc

        except httpx.RequestError as exc:
            raise TmdbRequestError(
                "Could not complete TMDB request.",
                path=path,
            ) from exc

        if not response.is_success:
            (
                message,
                tmdb_status_code,
            ) = _extract_tmdb_error(
                response,
            )

            raise TmdbHttpError(
                http_status_code=response.status_code,
                message=message,
                path=path,
                tmdb_status_code=tmdb_status_code,
                retry_after_seconds=_extract_retry_after_seconds(
                    response,
                ),
            )

        try:
            return response.json()

        except ValueError as exc:
            raise TmdbResponseError(
                "TMDB returned invalid JSON.",
                path=path,
            ) from exc

    # =========================================================================
    # Authentication
    # =========================================================================

    def _request_headers(self) -> dict[str, str]:
        """Return headers shared by authenticated TMDB requests.

        Credentials are constructed only at request time and are never exposed
        through public properties or exception messages.
        """

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
        """Build a complete TMDB URL from a normalized endpoint path."""

        return f"{self._base_url}{path}"

    # =========================================================================
    # Lifecycle
    # =========================================================================

    async def aclose(self) -> None:
        """Close resources owned by this request transport.

        Calling this method more than once is safe.

        Externally supplied ``httpx.AsyncClient`` instances are intentionally
        left open because their lifecycle belongs to the caller.
        """

        if self._closed:
            return

        self._closed = True

        if self._owns_http_client:
            await self._http_client.aclose()

    async def close(self) -> None:
        """Close the request transport.

        This alias exists primarily for readability in application-lifespan
        code.
        """

        await self.aclose()

    async def __aenter__(
        self,
    ) -> TmdbRequestClient:
        """Enter an asynchronous context manager."""

        self._ensure_open()

        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Exit an asynchronous context manager and release owned resources."""

        await self.aclose()

    # =========================================================================
    # Lifecycle validation
    # =========================================================================

    def _ensure_open(self) -> None:
        """Raise when the TMDB transport can no longer execute requests."""

        if self.is_closed:
            raise TmdbClientClosedError()


# =============================================================================
# Access-token validation
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
# Base-URL validation
# =============================================================================


def _normalize_base_url(
    value: str,
) -> str:
    """Normalize and validate the configured TMDB API base URL.

    Only HTTPS URLs are accepted because authentication credentials must never
    be transmitted over an unencrypted connection.

    Query strings, fragments and embedded user information are rejected so the
    base URL remains a predictable API origin rather than an arbitrary request
    template.
    """

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("TMDB base URL must be a string.")

    normalized = value.strip().rstrip(
        "/",
    )

    if not normalized:
        raise ValueError("TMDB base URL must not be blank.")

    parsed = urlsplit(
        normalized,
    )

    if parsed.scheme.lower() != "https":
        raise ValueError("TMDB base URL must use HTTPS.")

    if parsed.hostname is None:
        raise ValueError("TMDB base URL must include a host.")

    if parsed.username is not None or parsed.password is not None:
        raise ValueError("TMDB base URL must not include user information.")

    if parsed.query:
        raise ValueError("TMDB base URL must not include a query string.")

    if parsed.fragment:
        raise ValueError("TMDB base URL must not include a fragment.")

    return normalized


# =============================================================================
# Endpoint-path validation
# =============================================================================


def _normalize_path(
    value: str,
) -> str:
    """Normalize and validate a relative TMDB endpoint path.

    Full URLs are deliberately rejected.

    Query parameters must be supplied separately through ``params`` so error
    messages and logs can safely retain endpoint paths without accidentally
    capturing user queries or other request data.
    """

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("TMDB endpoint path must be a string.")

    normalized = value.strip()

    if not normalized:
        raise ValueError("TMDB endpoint path must not be blank.")

    if "://" in normalized or normalized.startswith("//"):
        raise ValueError(
            "TMDB endpoint path must be relative to the configured "
            "TMDB base URL."
        )

    if "?" in normalized:
        raise ValueError("TMDB endpoint path must not contain a query string.")

    if "#" in normalized:
        raise ValueError("TMDB endpoint path must not contain a fragment.")

    if "\\" in normalized:
        raise ValueError("TMDB endpoint path must use forward slashes.")

    if not normalized.startswith("/"):
        normalized = f"/{normalized}"

    path_segments = normalized.split(
        "/",
    )

    if any(
        segment
        in {
            ".",
            "..",
        }
        for segment in path_segments
    ):
        raise ValueError(
            "TMDB endpoint path must not contain relative path segments."
        )

    return normalized


# =============================================================================
# Language validation
# =============================================================================


def _normalize_language(
    value: str,
) -> str:
    """Normalize a TMDB localization language.

    Underscores are converted to hyphens so common locale representations such
    as:

        en_US
        it_IT
        zh_CN

    become:

        en-US
        it-IT
        zh-CN

    Endpoint groups should obtain language values through
    :meth:`TmdbRequestClient.resolve_language`.
    """

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

    if any(character.isspace() for character in normalized):
        raise ValueError("TMDB language must not contain whitespace.")

    return normalized


# =============================================================================
# Timeout validation
# =============================================================================


def _normalize_timeout_seconds(
    value: float,
) -> float:
    """Normalize and validate the per-request timeout."""

    # ``bool`` subclasses ``int`` in Python and must therefore be rejected
    # explicitly.
    if isinstance(
        value,
        bool,
    ):
        raise TypeError(
            "TMDB timeout must be a positive finite number of seconds."
        )

    try:
        normalized = float(
            value,
        )

    except (
        TypeError,
        ValueError,
    ) as exc:
        raise TypeError(
            "TMDB timeout must be a positive finite number of seconds."
        ) from exc

    if (
        not math.isfinite(
            normalized,
        )
        or normalized <= 0.0
    ):
        raise ValueError(
            "TMDB timeout must be a positive finite number of seconds."
        )

    return normalized


# =============================================================================
# TMDB error-response extraction
# =============================================================================


def _extract_tmdb_error(
    response: httpx.Response,
) -> tuple[str, int | None]:
    """Extract safe structured information from a TMDB error response.

    TMDB error payloads commonly contain:

        {
            "success": false,
            "status_code": 34,
            "status_message": "The resource you requested could not be found."
        }

    Only the application-level ``status_code`` and human-readable
    ``status_message`` are retained.

    Arbitrary response bodies are deliberately not included in exceptions.
    """

    try:
        payload = response.json()

    except ValueError:
        payload = None

    tmdb_status_code: int | None = None

    if isinstance(
        payload,
        dict,
    ):
        raw_status_code = payload.get(
            "status_code",
        )

        if isinstance(
            raw_status_code,
            int,
        ) and not isinstance(
            raw_status_code,
            bool,
        ):
            tmdb_status_code = raw_status_code

        raw_status_message = payload.get(
            "status_message",
        )

        if isinstance(
            raw_status_message,
            str,
        ):
            status_message = raw_status_message.strip()

            if status_message:
                return (
                    status_message,
                    tmdb_status_code,
                )

    reason = response.reason_phrase.strip()

    if reason:
        return (
            reason,
            tmdb_status_code,
        )

    return (
        "Unknown TMDB error.",
        tmdb_status_code,
    )


# =============================================================================
# Retry-After extraction
# =============================================================================


def _extract_retry_after_seconds(
    response: httpx.Response,
) -> int | None:
    """Extract an integer delay from an HTTP ``Retry-After`` header.

    HTTP permits either:

    - an integer number of seconds; or
    - an HTTP date.

    Cineara currently retains only the integer-delay representation because it
    is directly useful to retry/backoff policy.

    Retry decisions themselves belong outside this transport layer.
    """

    raw_value = response.headers.get(
        "Retry-After",
    )

    if raw_value is None:
        return None

    normalized = raw_value.strip()

    if not normalized.isdigit():
        return None

    retry_after_seconds = int(
        normalized,
    )

    if retry_after_seconds < 0:
        return None

    return retry_after_seconds


# =============================================================================
# Response-model naming
# =============================================================================


def _model_name(
    model: type[BaseModel],
) -> str:
    """Return a useful model name for structured response errors.

    Pydantic generic models may have generated names such as:

        TmdbSearchPage[TmdbMovieSearchResult]

    which are useful when diagnosing upstream schema changes.
    """

    return model.__name__
