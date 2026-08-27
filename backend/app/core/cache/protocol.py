"""Shared asynchronous cache protocols used by Cineara services.

Feature modules should type against the smallest protocol they require rather
than against a concrete cache implementation.

``KeyValueCache`` is sufficient for cache-aside consumers such as Search.
``ManageableCache`` extends that contract with lifecycle and health operations
used by application bootstrap, readiness checks, and integration tests.

Serialization is deliberately outside this layer. Callers store text or bytes
and remain responsible for encoding domain-specific payloads.
"""

from __future__ import annotations

from typing import Protocol, runtime_checkable

# =============================================================================
# Cache values
# =============================================================================


type CacheValue = str | bytes


# =============================================================================
# Minimal key-value protocol
# =============================================================================


@runtime_checkable
class KeyValueCache(Protocol):
    """Minimal asynchronous key-value cache contract."""

    async def get(
        self,
        key: str,
    ) -> CacheValue | None:
        """Return the stored value for ``key`` or ``None``."""

        ...

    async def set(
        self,
        key: str,
        value: CacheValue,
        *,
        ttl_seconds: int,
    ) -> None:
        """Store ``value`` for ``key`` with a positive TTL."""

        ...


# =============================================================================
# Managed cache protocol
# =============================================================================


@runtime_checkable
class ManageableCache(
    KeyValueCache,
    Protocol,
):
    """Cache contract including lifecycle and health operations."""

    @property
    def is_closed(self) -> bool:
        """Return whether this cache adapter has been closed."""

        ...

    async def delete(
        self,
        key: str,
    ) -> bool:
        """Delete ``key`` and return whether a value was removed."""

        ...

    async def exists(
        self,
        key: str,
    ) -> bool:
        """Return whether ``key`` currently exists."""

        ...

    async def ping(self) -> bool:
        """Return whether the cache backend is reachable."""

        ...

    async def aclose(self) -> None:
        """Close resources owned by this cache adapter."""

        ...
