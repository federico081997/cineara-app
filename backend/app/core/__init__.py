"""Public exports for Cineara core infrastructure.

The ``core`` package contains application-wide infrastructure and
configuration shared across feature modules.

The package root exposes only stable configuration APIs. More specialized
infrastructure, such as caching, remains available from its dedicated
subpackage:

    app.core.cache

Keeping the root surface small prevents unrelated feature modules from becoming
coupled to concrete infrastructure implementations.
"""

from __future__ import annotations

from .config import (
    DependencyStatus,
    EnvironmentName,
    LogLevel,
    Settings,
    TrendingTimeWindow,
    check_postgres_ready,
    get_settings,
)

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "DependencyStatus",
    "EnvironmentName",
    "LogLevel",
    "Settings",
    "TrendingTimeWindow",
    "check_postgres_ready",
    "get_settings",
]
