"""Exception hierarchy for Cineara's TMDB integration.

This module defines the errors that may cross the internal boundary of the
TMDB integration.

The exception hierarchy is deliberately independent of FastAPI, Search,
catalogue classification, caching, and other Cineara feature logic. Resource
clients such as Search, Movies, TV, People, Seasons, and Discovery may all
raise these exceptions through the shared TMDB request layer.

Higher application layers are responsible for translating these integration
errors into feature-specific or HTTP-facing errors where appropriate.

Exception hierarchy
-------------------

TmdbClientError
├── TmdbRequestError
│   └── TmdbTimeoutError
├── TmdbHttpError
├── TmdbResponseError
└── TmdbClientClosedError

The distinction is intentional:

``TmdbRequestError``
    The request could not successfully reach TMDB or receive an HTTP response.

``TmdbTimeoutError``
    A specialized transport failure caused by a request timeout.

``TmdbHttpError``
    TMDB returned an HTTP response, but its status was unsuccessful.

``TmdbResponseError``
    TMDB returned a successful HTTP response, but its body could not be
    decoded or validated into the expected raw TMDB model.

``TmdbClientClosedError``
    Code attempted to use the TMDB transport after its lifecycle had ended.

These exceptions must not contain raw authentication tokens, complete request
URLs containing sensitive query parameters, or arbitrary response bodies.
"""

from __future__ import annotations

# =============================================================================
# Base exception
# =============================================================================


class TmdbClientError(Exception):
    """Base exception for operational failures in the TMDB integration.

    Catching this exception handles any expected failure produced while
    communicating with or interpreting responses from TMDB.

    Programming errors such as invalid local method arguments should normally
    continue to use standard exceptions such as ``TypeError`` and
    ``ValueError`` rather than being wrapped in ``TmdbClientError``.
    """


# =============================================================================
# Transport errors
# =============================================================================


class TmdbRequestError(TmdbClientError):
    """Raised when a request cannot successfully communicate with TMDB.

    Examples include:

    - DNS resolution failures;
    - connection failures;
    - connection resets;
    - TLS/transport failures;
    - other HTTP-client request errors occurring before a usable HTTP
      response is received.

    Parameters
    ----------
    message:
        Safe human-readable description of the transport failure.

    path:
        Optional TMDB endpoint path, such as ``/search/movie``. Only the
        endpoint path should be stored here. Query parameters and
        authentication information should not be included.
    """

    def __init__(
        self,
        message: str,
        *,
        path: str | None = None,
    ) -> None:
        """Initialize a TMDB request error."""

        self.message = message
        self.path = path

        super().__init__(
            _format_error_message(
                message,
                path=path,
            )
        )


class TmdbTimeoutError(TmdbRequestError):
    """Raised when a request to TMDB exceeds its configured timeout.

    Timeout errors are represented separately from other transport failures so
    higher layers may translate or observe them differently without inspecting
    error-message text.

    Parameters
    ----------
    message:
        Safe human-readable timeout description.

    path:
        Optional TMDB endpoint path.

    timeout_seconds:
        Configured timeout duration when known. This value is informational
        only. Retry policy belongs to a higher application layer.
    """

    def __init__(
        self,
        message: str,
        *,
        path: str | None = None,
        timeout_seconds: float | None = None,
    ) -> None:
        """Initialize a TMDB timeout error."""

        self.timeout_seconds = timeout_seconds

        super().__init__(
            message,
            path=path,
        )


# =============================================================================
# HTTP errors
# =============================================================================


class TmdbHttpError(TmdbClientError):
    """Raised when TMDB returns a non-successful HTTP response.

    Two status-code concepts are intentionally kept separate:

    ``http_status_code``
        The actual HTTP response status, for example ``401``, ``404``,
        ``429``, or ``500``.

    ``tmdb_status_code``
        TMDB's optional application-level ``status_code`` value contained in
        some JSON error responses.

    They are not guaranteed to be the same value and should therefore never
    share the same field.

    Parameters
    ----------
    http_status_code:
        HTTP status returned by TMDB.

    message:
        Safe human-readable message derived from TMDB's response.

    path:
        Optional endpoint path responsible for the error.

    tmdb_status_code:
        Optional TMDB application-level status code extracted from its JSON
        error payload.

    retry_after_seconds:
        Optional integer delay derived from the HTTP ``Retry-After`` header.
    """

    def __init__(
        self,
        *,
        http_status_code: int,
        message: str,
        path: str | None = None,
        tmdb_status_code: int | None = None,
        retry_after_seconds: int | None = None,
    ) -> None:
        """Initialize a TMDB HTTP error."""

        self.http_status_code = http_status_code
        self.message = message
        self.path = path
        self.tmdb_status_code = tmdb_status_code
        self.retry_after_seconds = retry_after_seconds

        error_message = f"TMDB returned HTTP {http_status_code}: {message}"

        if path is not None:
            error_message = f"{error_message} [path={path}]"

        if tmdb_status_code is not None:
            error_message = (
                f"{error_message} [tmdb_status_code={tmdb_status_code}]"
            )

        if retry_after_seconds is not None:
            error_message = (
                f"{error_message} [retry_after={retry_after_seconds}s]"
            )

        super().__init__(
            error_message,
        )

    @property
    def status_code(self) -> int:
        """Return the HTTP status code.

        This alias keeps call sites concise while ``http_status_code`` remains
        the unambiguous structured attribute.
        """

        return self.http_status_code


# =============================================================================
# Response errors
# =============================================================================


class TmdbResponseError(TmdbClientError):
    """Raised when a successful TMDB response cannot be interpreted safely.

    Typical causes include:

    - invalid JSON;
    - an unexpected top-level response structure;
    - Pydantic validation failure;
    - fields incompatible with the expected raw TMDB response model.

    This is distinct from ``TmdbHttpError`` because TMDB may return HTTP 2xx
    while still providing a payload that Cineara cannot safely consume.

    Parameters
    ----------
    message:
        Safe description of the response-processing failure.

    path:
        Optional endpoint path that produced the response.

    model_name:
        Optional name of the raw Pydantic model that could not validate the
        response.
    """

    def __init__(
        self,
        message: str,
        *,
        path: str | None = None,
        model_name: str | None = None,
    ) -> None:
        """Initialize a TMDB response error."""

        self.message = message
        self.path = path
        self.model_name = model_name

        error_message = _format_error_message(
            message,
            path=path,
        )

        if model_name is not None:
            error_message = f"{error_message} [model={model_name}]"

        super().__init__(
            error_message,
        )


# =============================================================================
# Lifecycle errors
# =============================================================================


class TmdbClientClosedError(TmdbClientError):
    """Raised when code attempts to use a closed TMDB client.

    This normally indicates an application-lifecycle error rather than an
    upstream TMDB failure.
    """

    def __init__(self) -> None:
        """Initialize a closed-client error."""

        super().__init__("TMDB client has already been closed.")


# =============================================================================
# Internal formatting
# =============================================================================


def _format_error_message(
    message: str,
    *,
    path: str | None,
) -> str:
    """Format a safe TMDB integration error message.

    Endpoint paths are useful for logs and observability while avoiding the
    accidental inclusion of query parameters or authentication data.
    """

    if path is None:
        return message

    return f"{message} [path={path}]"
