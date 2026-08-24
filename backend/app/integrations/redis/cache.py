"""Reusable Redis-backed JSON cache for Cineara.

This module provides a generic asynchronous JSON-cache abstraction shared by
backend features.

The cache is intentionally domain-agnostic. It knows nothing about Search,
TMDB, catalogue entities, recommendations, classification, or FastAPI routes.

Feature modules are responsible for:

- cache-key design;
- cache-key versioning;
- TTL policy;
- serialization shape;
- validation of cached payloads.

Example logical keys
--------------------

Search source page:

    search-source:v1:standard:all:en-US:dune:1

Feature-specific data:

    feature-name:v1:resource-id

An optional application-wide prefix can be applied by ``Cache``:

    cineara:search-source:v1:standard:all:en-US:dune:1

Batch operations
----------------

``Cache`` supports both individual and batched operations:

    get_json(...)
    set_json(...)
    delete(...)

    get_many_json(...)
    set_many_json(...)
    delete_many(...)

Batch reads use Redis ``MGET`` and batch writes use a non-transactional Redis
pipeline, reducing network round trips when a feature needs to process several
independent cache entries.

The cache remains model-agnostic. Pydantic models should be converted by the
owning feature using ``model_dump(mode="json")`` before storage and validated
again when read.

Lifecycle
---------

``Cache`` does not create or close Redis connections.

Create one asynchronous Redis client during application startup and inject it
into ``Cache``:

    redis = Redis.from_url(...)
    cache = Cache(redis)

This allows Redis connection pooling to be shared across backend features.
"""

from __future__ import annotations

import json
from collections.abc import Iterable, Mapping
from typing import Any

from redis.asyncio import Redis
from redis.exceptions import RedisError


# =============================================================================
# Exceptions
# =============================================================================


class CacheError(Exception):
    """Base exception raised by Cineara's cache abstraction."""


class CacheBackendError(CacheError):
    """Raised when Redis cannot complete a cache operation."""


class CacheSerializationError(CacheError):
    """Raised when cached JSON cannot be encoded or decoded."""


# =============================================================================
# Cache
# =============================================================================


class Cache:
    """Generic asynchronous JSON cache backed by Redis.

    Parameters
    ----------
    redis:
        Existing asynchronous Redis client.

        ``Cache`` does not own the client and therefore does not close it.

    key_prefix:
        Optional global prefix applied to every key.

        Example:

            key_prefix="cineara"

        turns:

            search-source:v1:standard:all:en-US:dune:1

        into:

            cineara:search-source:v1:standard:all:en-US:dune:1

        Feature modules still own the logical key after that optional prefix.
    """

    def __init__(
        self,
        redis: Redis,
        *,
        key_prefix: str | None = None,
    ) -> None:
        """Initialize the cache."""

        if redis is None:
            raise TypeError("redis must be an asynchronous Redis client.")

        self._redis = redis
        self._key_prefix = _normalize_prefix(
            key_prefix,
        )

    # =========================================================================
    # Get one JSON value
    # =========================================================================

    async def get_json(
        self,
        key: str,
    ) -> Any | None:
        """Read and decode one JSON value.

        ``None`` means the cache key does not exist.
        """

        redis_key = self._build_key(
            key,
        )

        try:
            raw_value = await self._redis.get(
                redis_key,
            )

        except RedisError as exc:
            raise CacheBackendError(
                f"Failed to read cache key {redis_key!r}."
            ) from exc

        if raw_value is None:
            return None

        return _decode_json_value(
            raw_value,
            key=redis_key,
        )

    # =========================================================================
    # Get many JSON values
    # =========================================================================

    async def get_many_json(
        self,
        keys: Iterable[str],
    ) -> dict[str, Any | None]:
        """Read several logical keys with one Redis ``MGET``.

        Parameters
        ----------
        keys:
            Logical cache keys.

            Duplicate keys are de-duplicated while preserving first-seen order.

        Returns
        -------
        dict[str, Any | None]
            Mapping from each normalized logical key to its decoded value.

            ``None`` means that particular key was not present.

        Notes
        -----
        Returning logical keys rather than prefixed Redis keys keeps callers
        independent from the cache namespace implementation.
        """

        logical_keys = _normalize_keys(
            keys,
        )

        if not logical_keys:
            return {}

        redis_keys = [
            self._build_key(
                key,
            )
            for key in logical_keys
        ]

        try:
            raw_values = await self._redis.mget(
                redis_keys,
            )

        except RedisError as exc:
            raise CacheBackendError(
                "Failed to read multiple cache keys."
            ) from exc

        if len(raw_values) != len(logical_keys):
            raise CacheBackendError(
                "Redis returned an unexpected number of values for MGET."
            )

        result: dict[str, Any | None] = {}

        for logical_key, redis_key, raw_value in zip(
            logical_keys,
            redis_keys,
            raw_values,
            strict=True,
        ):
            if raw_value is None:
                result[logical_key] = None
                continue

            result[logical_key] = _decode_json_value(
                raw_value,
                key=redis_key,
            )

        return result

    # =========================================================================
    # Set one JSON value
    # =========================================================================

    async def set_json(
        self,
        key: str,
        value: Any,
        *,
        ttl_seconds: int | None = None,
    ) -> None:
        """Serialize and store one JSON value.

        Pydantic models should normally be converted by the caller:

            await cache.set_json(
                key,
                model.model_dump(mode="json"),
                ttl_seconds=...,
            )
        """

        redis_key = self._build_key(
            key,
        )
        normalized_ttl = _normalize_ttl(
            ttl_seconds,
        )
        encoded = _encode_json_value(
            value,
            key=redis_key,
        )

        try:
            await self._redis.set(
                redis_key,
                encoded,
                ex=normalized_ttl,
            )

        except RedisError as exc:
            raise CacheBackendError(
                f"Failed to write cache key {redis_key!r}."
            ) from exc

    # =========================================================================
    # Set many JSON values
    # =========================================================================

    async def set_many_json(
        self,
        values: Mapping[str, Any],
        *,
        ttl_seconds: int | None = None,
    ) -> None:
        """Serialize and store many values with one Redis pipeline round trip.

        All values use the same TTL. Feature-specific code that needs different
        TTLs should call this method separately for each TTL group.

        ``pipeline(transaction=False)`` is intentional: these independent cache
        writes do not require Redis MULTI/EXEC transaction semantics.
        """

        if not isinstance(
            values,
            Mapping,
        ):
            raise TypeError(
                "Cache batch values must be a mapping of key to JSON value."
            )

        if not values:
            return

        normalized_ttl = _normalize_ttl(
            ttl_seconds,
        )

        prepared: list[tuple[str, str]] = []
        seen_logical_keys: set[str] = set()

        for raw_key, value in values.items():
            logical_key = _normalize_key(
                raw_key,
            )

            if logical_key in seen_logical_keys:
                continue

            seen_logical_keys.add(
                logical_key,
            )

            redis_key = self._build_key(
                logical_key,
            )

            encoded = _encode_json_value(
                value,
                key=redis_key,
            )

            prepared.append(
                (
                    redis_key,
                    encoded,
                )
            )

        try:
            async with self._redis.pipeline(
                transaction=False,
            ) as pipeline:
                for redis_key, encoded in prepared:
                    pipeline.set(
                        redis_key,
                        encoded,
                        ex=normalized_ttl,
                    )

                await pipeline.execute()

        except RedisError as exc:
            raise CacheBackendError(
                "Failed to write multiple cache keys."
            ) from exc

    # =========================================================================
    # Delete one value
    # =========================================================================

    async def delete(
        self,
        key: str,
    ) -> bool:
        """Delete one cache value.

        Returns ``True`` when Redis removed the key and ``False`` when the key
        did not exist.
        """

        redis_key = self._build_key(
            key,
        )

        try:
            deleted_count = await self._redis.delete(
                redis_key,
            )

        except RedisError as exc:
            raise CacheBackendError(
                f"Failed to delete cache key {redis_key!r}."
            ) from exc

        return deleted_count > 0

    # =========================================================================
    # Delete many values
    # =========================================================================

    async def delete_many(
        self,
        keys: Iterable[str],
    ) -> int:
        """Delete several logical keys with one Redis request.

        Returns the number of keys Redis actually removed.
        """

        logical_keys = _normalize_keys(
            keys,
        )

        if not logical_keys:
            return 0

        redis_keys = [
            self._build_key(
                key,
            )
            for key in logical_keys
        ]

        try:
            deleted_count = await self._redis.delete(
                *redis_keys,
            )

        except RedisError as exc:
            raise CacheBackendError(
                "Failed to delete multiple cache keys."
            ) from exc

        return int(
            deleted_count,
        )

    # =========================================================================
    # Key construction
    # =========================================================================

    def _build_key(
        self,
        key: str,
    ) -> str:
        """Validate a logical key and apply the optional namespace."""

        normalized_key = _normalize_key(
            key,
        )

        if self._key_prefix is None:
            return normalized_key

        return f"{self._key_prefix}:{normalized_key}"


# =============================================================================
# JSON encoding
# =============================================================================


def _encode_json_value(
    value: Any,
    *,
    key: str,
) -> str:
    """Encode one JSON-compatible value for Redis storage."""

    try:
        return json.dumps(
            value,
            ensure_ascii=False,
            separators=(
                ",",
                ":",
            ),
        )

    except (
            TypeError,
            ValueError,
    ) as exc:
        raise CacheSerializationError(
            f"Value for cache key {key!r} is not JSON serializable."
        ) from exc


# =============================================================================
# JSON decoding
# =============================================================================


def _decode_json_value(
    raw_value: Any,
    *,
    key: str,
) -> Any:
    """Decode one Redis value into JSON-compatible Python data."""

    if isinstance(
        raw_value,
        bytes,
    ):
        try:
            raw_json = raw_value.decode(
                "utf-8",
            )

        except UnicodeDecodeError as exc:
            raise CacheSerializationError(
                f"Cache key {key!r} contains invalid UTF-8."
            ) from exc

    elif isinstance(
        raw_value,
        str,
    ):
        raw_json = raw_value

    else:
        raise CacheSerializationError(
            f"Cache key {key!r} returned an unsupported "
            f"value type: {type(raw_value).__name__}."
        )

    try:
        return json.loads(
            raw_json,
        )

    except json.JSONDecodeError as exc:
        raise CacheSerializationError(
            f"Cache key {key!r} contains invalid JSON."
        ) from exc


# =============================================================================
# Key validation
# =============================================================================


def _normalize_key(
    key: str,
) -> str:
    """Validate one logical Redis cache key."""

    if not isinstance(
        key,
        str,
    ):
        raise TypeError("Cache key must be a string.")

    normalized = key.strip()

    if not normalized:
        raise ValueError("Cache key must not be blank.")

    return normalized


def _normalize_keys(
    keys: Iterable[str],
) -> list[str]:
    """Normalize and de-duplicate logical keys while preserving order."""

    if isinstance(
        keys,
        str,
    ):
        # Treat one string as one key rather than as an iterable of characters.
        iterable: Iterable[str] = (keys,)
    else:
        iterable = keys

    result: list[str] = []
    seen: set[str] = set()

    for raw_key in iterable:
        normalized = _normalize_key(
            raw_key,
        )

        if normalized in seen:
            continue

        seen.add(
            normalized,
        )
        result.append(
            normalized,
        )

    return result


# =============================================================================
# Prefix validation
# =============================================================================


def _normalize_prefix(
    prefix: str | None,
) -> str | None:
    """Normalize an optional global cache-key prefix."""

    if prefix is None:
        return None

    if not isinstance(
        prefix,
        str,
    ):
        raise TypeError("Cache key prefix must be a string or None.")

    normalized = prefix.strip().strip(
        ":",
    )

    if not normalized:
        return None

    return normalized


# =============================================================================
# TTL validation
# =============================================================================


def _normalize_ttl(
    ttl_seconds: int | None,
) -> int | None:
    """Validate an optional cache TTL."""

    if ttl_seconds is None:
        return None

    # bool subclasses int in Python.
    if isinstance(
        ttl_seconds,
        bool,
    ) or not isinstance(
        ttl_seconds,
        int,
    ):
        raise TypeError(
            "Cache TTL must be an integer number of seconds or None."
        )

    if ttl_seconds <= 0:
        raise ValueError("Cache TTL must be greater than 0 seconds.")

    return ttl_seconds


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "Cache",
    "CacheBackendError",
    "CacheError",
    "CacheSerializationError",
]
