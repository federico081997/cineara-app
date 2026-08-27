"""Public cache infrastructure exports for Cineara.

Feature modules should generally depend on ``KeyValueCache`` and
``CacheError`` rather than importing the Redis implementation directly.

Application bootstrap may construct ``RedisCache`` and own its lifecycle.
"""

from __future__ import annotations

from .exceptions import (
    CacheBackendError,
    CacheClosedError,
    CacheConnectionError,
    CacheError,
    CacheTimeoutError,
)
from .protocol import (
    CacheValue,
    KeyValueCache,
    ManageableCache,
)
from .redis import RedisCache

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "CacheBackendError",
    "CacheClosedError",
    "CacheConnectionError",
    "CacheError",
    "CacheTimeoutError",
    "CacheValue",
    "KeyValueCache",
    "ManageableCache",
    "RedisCache",
]
