"""Application-level exceptions for Cineara cache infrastructure.

Cache consumers should depend on these exceptions rather than on exceptions
from a concrete backend such as Redis.

Concrete cache adapters are responsible for translating provider-specific
failures into this hierarchy. This keeps feature modules independent of the
selected cache technology and allows cache implementations to change without
rewriting application services.
"""

from __future__ import annotations

# =============================================================================
# Base cache exception
# =============================================================================


class CacheError(RuntimeError):
    """Base exception raised by Cineara cache infrastructure."""


# =============================================================================
# Lifecycle
# =============================================================================


class CacheClosedError(CacheError):
    """Raised when an operation is attempted on a closed cache adapter."""


# =============================================================================
# Infrastructure failures
# =============================================================================


class CacheConnectionError(CacheError):
    """Raised when the cache backend cannot be reached."""


class CacheTimeoutError(CacheError):
    """Raised when a cache operation exceeds its configured timeout."""


class CacheBackendError(CacheError):
    """Raised for other backend failures during a cache operation."""
