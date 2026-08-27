"""Redis implementation of Cineara's asynchronous cache protocols.

The adapter translates ``redis-py`` exceptions into Cineara's stable cache
exception hierarchy so application services never need to import Redis-specific
exception types.

The adapter supports either:

- an externally created ``redis.asyncio.Redis`` client, whose lifecycle remains
  owned by the caller; or
- a client created through ``RedisCache.from_url()``, which is owned and closed
  by the adapter.

Values are stored without application-level serialization. Feature services
remain responsible for encoding and decoding their own payloads.

A narrow internal async Redis protocol is used for command typing. This keeps
Cineara independent of version-specific ``redis-py`` type annotations while
preserving the actual asynchronous Redis runtime API.
"""

from __future__ import annotations

import math
from collections.abc import Awaitable
from types import TracebackType
from typing import Protocol, cast
from urllib.parse import urlparse

from redis.asyncio import Redis
from redis.exceptions import (
    ConnectionError as RedisConnectionError,
)
from redis.exceptions import RedisError
from redis.exceptions import (
    TimeoutError as RedisTimeoutError,
)

from .exceptions import (
    CacheBackendError,
    CacheClosedError,
    CacheConnectionError,
    CacheTimeoutError,
)
from .protocol import CacheValue

# =============================================================================
# Async Redis typing boundary
# =============================================================================


class _AsyncRedisClient(Protocol):
    """Subset of the asynchronous Redis API required by ``RedisCache``.

    ``redis-py`` versions have differed in how some asyncio commands are
    represented to static type checkers. This protocol defines the contract
    Cineara actually relies on and isolates the rest of the application from
    those third-party typing details.
    """

    def get(
        self,
        key: str,
    ) -> Awaitable[str | bytes | None]:
        """Return the value stored under ``key``."""

        ...

    def set(
        self,
        key: str,
        value: str | bytes,
        *,
        ex: int,
    ) -> Awaitable[bool | None]:
        """Store ``value`` with an expiration in seconds."""

        ...

    def delete(
        self,
        *keys: str,
    ) -> Awaitable[int]:
        """Delete one or more keys and return the number removed."""

        ...

    def exists(
        self,
        *keys: str,
    ) -> Awaitable[int]:
        """Return the number of supplied keys that exist."""

        ...

    def ping(self) -> Awaitable[bool]:
        """Return whether the Redis backend responds."""

        ...

    def aclose(self) -> Awaitable[None]:
        """Close the asynchronous Redis client."""

        ...


# =============================================================================
# Redis cache
# =============================================================================


class RedisCache:
    """Asynchronous Redis-backed Cineara cache adapter."""

    __slots__ = (
        "_client",
        "_closed",
        "_key_prefix",
        "_owns_client",
    )

    def __init__(
        self,
        *,
        client: Redis,
        owns_client: bool = False,
        key_prefix: str | None = None,
    ) -> None:
        """Create a Redis cache adapter.

        Parameters
        ----------
        client:
            Configured asynchronous ``redis-py`` client.

        owns_client:
            Whether this adapter owns ``client`` and must close it from
            ``aclose()``.

        key_prefix:
            Optional namespace prepended to every key.

            A prefix such as ``"cineara:production"`` allows multiple
            environments to share a Redis deployment without key collisions.
        """

        if not isinstance(
            client,
            Redis,
        ):
            raise TypeError(
                "client must be an asynchronous redis.Redis instance."
            )

        if not isinstance(
            owns_client,
            bool,
        ):
            raise TypeError("owns_client must be a bool.")

        self._client = cast(
            _AsyncRedisClient,
            cast(
                object,
                client,
            ),
        )

        self._owns_client = owns_client

        self._key_prefix = _normalize_key_prefix(
            key_prefix,
        )

        self._closed = False

    # =========================================================================
    # Construction
    # =========================================================================

    @classmethod
    def from_url(
        cls,
        url: str,
        *,
        key_prefix: str | None = None,
        decode_responses: bool = True,
        socket_timeout_seconds: float = 2.0,
        socket_connect_timeout_seconds: float = 2.0,
        health_check_interval_seconds: int = 30,
        max_connections: int = 20,
    ) -> RedisCache:
        """Create an owned Redis client from a Redis URL.

        Supported schemes are:

        - ``redis://``
        - ``rediss://``
        - ``unix://``

        ``decode_responses=True`` is the default because Cineara currently
        stores JSON and other textual cache payloads.

        Set ``decode_responses=False`` when byte responses are required.
        """

        normalized_url = _normalize_redis_url(
            url,
        )

        if not isinstance(
            decode_responses,
            bool,
        ):
            raise TypeError("decode_responses must be a bool.")

        socket_timeout = _normalize_positive_float(
            socket_timeout_seconds,
            name="socket_timeout_seconds",
        )

        socket_connect_timeout = _normalize_positive_float(
            socket_connect_timeout_seconds,
            name="socket_connect_timeout_seconds",
        )

        health_check_interval = _normalize_non_negative_int(
            health_check_interval_seconds,
            name="health_check_interval_seconds",
        )

        normalized_max_connections = _normalize_positive_int(
            max_connections,
            name="max_connections",
        )

        client = Redis.from_url(
            normalized_url,
            encoding="utf-8",
            decode_responses=decode_responses,
            socket_timeout=socket_timeout,
            socket_connect_timeout=socket_connect_timeout,
            health_check_interval=health_check_interval,
            max_connections=normalized_max_connections,
        )

        return cls(
            client=client,
            owns_client=True,
            key_prefix=key_prefix,
        )

    # =========================================================================
    # State
    # =========================================================================

    @property
    def is_closed(self) -> bool:
        """Return whether this adapter has been closed."""

        return self._closed

    # =========================================================================
    # Read
    # =========================================================================

    async def get(
        self,
        key: str,
    ) -> CacheValue | None:
        """Return a cached value or ``None`` when the key is absent."""

        self._ensure_open()

        namespaced_key = self._key(
            key,
        )

        try:
            value = await self._client.get(
                namespaced_key,
            )

        except RedisTimeoutError as exc:
            raise CacheTimeoutError("Redis GET operation timed out.") from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis GET operation failed because the backend "
                "could not be reached."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis GET operation failed.") from exc

        if value is None:
            return None

        if isinstance(
            value,
            (
                str,
                bytes,
            ),
        ):
            return value

        raise CacheBackendError(
            "Redis GET returned an unsupported value type."
        )

    # =========================================================================
    # Write
    # =========================================================================

    async def set(
        self,
        key: str,
        value: CacheValue,
        *,
        ttl_seconds: int,
    ) -> None:
        """Store a value with a positive expiration time."""

        self._ensure_open()

        namespaced_key = self._key(
            key,
        )

        normalized_value = _normalize_cache_value(
            value,
        )

        ttl = _normalize_positive_int(
            ttl_seconds,
            name="ttl_seconds",
        )

        try:
            stored = await self._client.set(
                namespaced_key,
                normalized_value,
                ex=ttl,
            )

        except RedisTimeoutError as exc:
            raise CacheTimeoutError("Redis SET operation timed out.") from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis SET operation failed because the backend "
                "could not be reached."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis SET operation failed.") from exc

        if not stored:
            raise CacheBackendError(
                "Redis SET operation did not confirm the write."
            )

    # =========================================================================
    # Delete
    # =========================================================================

    async def delete(
        self,
        key: str,
    ) -> bool:
        """Delete a key and return whether an entry was removed."""

        self._ensure_open()

        namespaced_key = self._key(
            key,
        )

        try:
            deleted = await self._client.delete(
                namespaced_key,
            )

        except RedisTimeoutError as exc:
            raise CacheTimeoutError(
                "Redis DELETE operation timed out."
            ) from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis DELETE operation failed because the backend "
                "could not be reached."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis DELETE operation failed.") from exc

        return deleted > 0

    # =========================================================================
    # Existence
    # =========================================================================

    async def exists(
        self,
        key: str,
    ) -> bool:
        """Return whether a key exists in Redis."""

        self._ensure_open()

        namespaced_key = self._key(
            key,
        )

        try:
            count = await self._client.exists(
                namespaced_key,
            )

        except RedisTimeoutError as exc:
            raise CacheTimeoutError(
                "Redis EXISTS operation timed out."
            ) from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis EXISTS operation failed because the backend "
                "could not be reached."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis EXISTS operation failed.") from exc

        return count > 0

    # =========================================================================
    # Health
    # =========================================================================

    async def ping(self) -> bool:
        """Return whether Redis responds to a health check."""

        self._ensure_open()

        try:
            response = await self._client.ping()

        except RedisTimeoutError as exc:
            raise CacheTimeoutError("Redis PING operation timed out.") from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis PING operation failed because the backend "
                "could not be reached."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis PING operation failed.") from exc

        return response

    # =========================================================================
    # Lifecycle
    # =========================================================================

    async def aclose(self) -> None:
        """Close resources owned by this adapter.

        The operation is idempotent.

        An externally supplied Redis client remains owned by its caller and is
        therefore not closed by this adapter.
        """

        if self._closed:
            return

        if not self._owns_client:
            self._closed = True
            return

        try:
            await self._client.aclose()

        except RedisTimeoutError as exc:
            raise CacheTimeoutError(
                "Redis client shutdown timed out."
            ) from exc

        except RedisConnectionError as exc:
            raise CacheConnectionError(
                "Redis client shutdown failed because the backend "
                "connection could not be closed cleanly."
            ) from exc

        except RedisError as exc:
            raise CacheBackendError("Redis client shutdown failed.") from exc

        self._closed = True

    async def __aenter__(self) -> RedisCache:
        """Enter an asynchronous context-manager scope."""

        self._ensure_open()

        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_value: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Close owned resources when leaving an async context."""

        await self.aclose()

    # =========================================================================
    # Key handling
    # =========================================================================

    def _key(
        self,
        value: str,
    ) -> str:
        """Validate a key and apply the configured Redis namespace."""

        key = _normalize_key(
            value,
        )

        if self._key_prefix is None:
            return key

        return f"{self._key_prefix}:{key}"

    def _ensure_open(self) -> None:
        """Raise when the adapter has already been closed."""

        if self._closed:
            raise CacheClosedError("Redis cache adapter is closed.")


# =============================================================================
# Key validation
# =============================================================================


def _normalize_key(
    value: str,
) -> str:
    """Validate and normalize a cache key."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("cache key must be a string.")

    normalized = value.strip()

    if not normalized:
        raise ValueError("cache key must not be blank.")

    if any(character.isspace() for character in normalized):
        raise ValueError("cache key must not contain whitespace.")

    return normalized


def _normalize_key_prefix(
    value: str | None,
) -> str | None:
    """Normalize an optional Redis key namespace."""

    if value is None:
        return None

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("key_prefix must be a string or None.")

    normalized = value.strip().strip(
        ":",
    )

    if not normalized:
        return None

    if any(character.isspace() for character in normalized):
        raise ValueError("key_prefix must not contain whitespace.")

    return normalized


# =============================================================================
# Cache-value validation
# =============================================================================


def _normalize_cache_value(
    value: CacheValue,
) -> CacheValue:
    """Validate a cache value."""

    if not isinstance(
        value,
        (
            str,
            bytes,
        ),
    ):
        raise TypeError("cache value must be str or bytes.")

    return value


# =============================================================================
# Redis URL validation
# =============================================================================


def _normalize_redis_url(
    value: str,
) -> str:
    """Validate a Redis connection URL without exposing credentials."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("Redis URL must be a string.")

    normalized = value.strip()

    if not normalized:
        raise ValueError("Redis URL must not be blank.")

    parsed = urlparse(
        normalized,
    )

    if parsed.scheme not in {
        "redis",
        "rediss",
        "unix",
    }:
        raise ValueError("Redis URL must use redis://, rediss://, or unix://.")

    if (
        parsed.scheme
        in {
            "redis",
            "rediss",
        }
        and parsed.hostname is None
    ):
        raise ValueError("Redis URL must include a hostname.")

    if parsed.scheme == "unix" and not parsed.path:
        raise ValueError("unix:// Redis URL must include a socket path.")

    return normalized


# =============================================================================
# Numeric validation
# =============================================================================


def _normalize_positive_int(
    value: int,
    *,
    name: str,
) -> int:
    """Validate a strictly positive integer."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError(f"{name} must be an integer.")

    if value < 1:
        raise ValueError(f"{name} must be greater than or equal to 1.")

    return value


def _normalize_non_negative_int(
    value: int,
    *,
    name: str,
) -> int:
    """Validate an integer greater than or equal to zero."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError(f"{name} must be an integer.")

    if value < 0:
        raise ValueError(f"{name} must be greater than or equal to 0.")

    return value


def _normalize_positive_float(
    value: int | float,
    *,
    name: str,
) -> float:
    """Validate a finite positive numeric value."""

    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        (
            int,
            float,
        ),
    ):
        raise TypeError(f"{name} must be a number.")

    normalized = float(
        value,
    )

    if (
        not math.isfinite(
            normalized,
        )
        or normalized <= 0
    ):
        raise ValueError(f"{name} must be a finite number greater than 0.")

    return normalized
