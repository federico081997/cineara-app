"""Validated runtime configuration for the Cineara backend.

Settings are loaded from ``CINEARA_*`` environment variables and an optional
local ``.env`` file.

This module owns configuration values and lightweight configuration-derived
helpers only. Application resources such as HTTP clients and Redis connections
are constructed by the FastAPI lifespan in ``app.main``.

Environment-variable examples
-----------------------------
``CINEARA_ENVIRONMENT``
    development, staging, production, or test.

``CINEARA_TMDB_READ_ACCESS_TOKEN``
    TMDB API read-access bearer token.

``CINEARA_REDIS_HOST``
    Redis hostname.

``CINEARA_SEARCH_MIN_QUERY_LENGTH``
    Minimum normalized Search query length.

The legacy shorthand ``CINEARA_ENV`` is also accepted for the environment
field.
"""

from __future__ import annotations

import asyncio
from contextlib import suppress
from functools import lru_cache
from typing import Literal
from urllib.parse import quote

from pydantic import (
    AliasChoices,
    BaseModel,
    ConfigDict,
    Field,
    SecretStr,
    field_validator,
)
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict,
)

# =============================================================================
# Configuration types
# =============================================================================


type EnvironmentName = Literal[
    "development",
    "staging",
    "production",
    "test",
]

type LogLevel = Literal[
    "CRITICAL",
    "ERROR",
    "WARNING",
    "INFO",
    "DEBUG",
]

type TrendingTimeWindow = Literal[
    "day",
    "week",
]


# =============================================================================
# Settings
# =============================================================================


class Settings(BaseSettings):
    """Validated Cineara backend runtime settings."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="CINEARA_",
        case_sensitive=False,
        extra="ignore",
    )

    # =========================================================================
    # Application
    # =========================================================================

    environment: EnvironmentName = Field(
        default="development",
        validation_alias=AliasChoices(
            "CINEARA_ENVIRONMENT",
            "CINEARA_ENV",
        ),
    )

    debug: bool = False

    log_level: LogLevel = "INFO"

    api_host: str = "0.0.0.0"

    api_port: int = Field(
        default=8000,
        ge=1,
        le=65535,
    )

    # =========================================================================
    # PostgreSQL
    # =========================================================================

    postgres_host: str = "localhost"

    postgres_port: int = Field(
        default=5432,
        ge=1,
        le=65535,
    )

    postgres_database: str = "cineara"

    postgres_user: str = "cineara"

    postgres_password: SecretStr = SecretStr("cineara_dev_password")

    # =========================================================================
    # Redis
    # =========================================================================

    redis_host: str = "localhost"

    redis_port: int = Field(
        default=6379,
        ge=1,
        le=65535,
    )

    redis_database: int = Field(
        default=0,
        ge=0,
    )

    redis_username: str | None = None

    redis_password: SecretStr | None = None

    redis_ssl: bool = False

    redis_decode_responses: bool = True

    redis_socket_timeout_seconds: float = Field(
        default=2.0,
        gt=0,
        le=60,
    )

    redis_socket_connect_timeout_seconds: float = Field(
        default=2.0,
        gt=0,
        le=60,
    )

    redis_health_check_interval_seconds: int = Field(
        default=30,
        ge=0,
    )

    redis_max_connections: int = Field(
        default=20,
        ge=1,
    )

    redis_key_prefix: str | None = None

    # =========================================================================
    # Infrastructure readiness
    # =========================================================================

    dependency_timeout_seconds: float = Field(
        default=1.0,
        gt=0,
        le=30,
    )

    # =========================================================================
    # TMDB
    # =========================================================================

    tmdb_read_access_token: SecretStr

    tmdb_base_url: str = "https://api.themoviedb.org/3"

    tmdb_language: str = "en-US"

    tmdb_request_timeout_seconds: float = Field(
        default=10.0,
        gt=0,
        le=60,
    )

    tmdb_max_connections: int = Field(
        default=20,
        ge=1,
    )

    tmdb_max_keepalive_connections: int = Field(
        default=10,
        ge=0,
    )

    tmdb_include_adult: bool = False

    # =========================================================================
    # Search
    # =========================================================================

    search_min_query_length: int = Field(
        default=2,
        ge=1,
        le=200,
    )

    search_cache_ttl_seconds: int = Field(
        default=300,
        ge=1,
    )

    search_overview_cache_ttl_seconds: int = Field(
        default=180,
        ge=1,
    )

    search_landing_cache_ttl_seconds: int = Field(
        default=600,
        ge=1,
    )

    search_overview_section_limit: int = Field(
        default=5,
        ge=1,
        le=20,
    )

    search_trending_limit: int = Field(
        default=12,
        ge=1,
        le=100,
    )

    search_trending_time_window: TrendingTimeWindow = "week"

    # =========================================================================
    # String validation
    # =========================================================================

    @field_validator(
        "api_host",
        "postgres_host",
        "postgres_database",
        "postgres_user",
        "redis_host",
        "tmdb_base_url",
        "tmdb_language",
    )
    @classmethod
    def _validate_required_text(
        cls,
        value: str,
    ) -> str:
        """Trim required string settings and reject blank values."""

        normalized = value.strip()

        if not normalized:
            raise ValueError("Configuration value must not be blank.")

        return normalized

    @field_validator(
        "redis_username",
        "redis_key_prefix",
    )
    @classmethod
    def _normalize_optional_text(
        cls,
        value: str | None,
    ) -> str | None:
        """Trim optional text and collapse blank values to ``None``."""

        if value is None:
            return None

        normalized = value.strip()

        return normalized or None

    @field_validator(
        "tmdb_read_access_token",
    )
    @classmethod
    def _validate_tmdb_access_token(
        cls,
        value: SecretStr,
    ) -> SecretStr:
        """Reject an empty TMDB bearer token."""

        if not value.get_secret_value().strip():
            raise ValueError("TMDB read-access token must not be blank.")

        return value

    # =========================================================================
    # Derived Redis configuration
    # =========================================================================

    @property
    def redis_url(self) -> str:
        """Return a Redis URL derived from validated Redis settings."""

        scheme = "rediss" if self.redis_ssl else "redis"

        credentials = _redis_credentials(
            username=self.redis_username,
            password=self.redis_password,
        )

        return (
            f"{scheme}://{credentials}"
            f"{self.redis_host}:{self.redis_port}/"
            f"{self.redis_database}"
        )

    @property
    def effective_redis_key_prefix(self) -> str:
        """Return the environment-scoped Redis namespace."""

        if self.redis_key_prefix is not None:
            return self.redis_key_prefix.strip(":")

        return f"cineara:{self.environment}"


# =============================================================================
# Readiness model
# =============================================================================


class DependencyStatus(BaseModel):
    """Readiness state for Cineara's required infrastructure."""

    model_config = ConfigDict(
        extra="forbid",
        frozen=True,
    )

    postgres: bool

    redis: bool

    @property
    def ready(self) -> bool:
        """Return whether every required dependency is reachable."""

        return self.postgres and self.redis


# =============================================================================
# PostgreSQL readiness
# =============================================================================


async def check_postgres_ready(
    settings: Settings,
) -> bool:
    """Check whether the configured PostgreSQL TCP endpoint is reachable.

    This is intentionally a connectivity check rather than a database query.
    Database migrations and schema-level health belong to the database layer.
    """

    if not isinstance(
        settings,
        Settings,
    ):
        raise TypeError("settings must be a Settings instance.")

    writer: asyncio.StreamWriter | None = None

    try:
        _, writer = await asyncio.wait_for(
            asyncio.open_connection(
                settings.postgres_host,
                settings.postgres_port,
            ),
            timeout=settings.dependency_timeout_seconds,
        )

    except (
        OSError,
        TimeoutError,
    ):
        return False

    finally:
        if writer is not None:
            writer.close()

            with suppress(
                ConnectionError,
                OSError,
            ):
                await writer.wait_closed()

    return True


# =============================================================================
# Settings access
# =============================================================================


@lru_cache(
    maxsize=1,
)
def get_settings() -> Settings:
    """Return the process-wide validated Settings instance."""

    return Settings()


# =============================================================================
# Redis URL helpers
# =============================================================================


def _redis_credentials(
    *,
    username: str | None,
    password: SecretStr | None,
) -> str:
    """Build the optional URL-encoded Redis authentication component."""

    raw_password = (
        password.get_secret_value() if password is not None else None
    )

    if username is None and raw_password is None:
        return ""

    encoded_username = quote(
        username or "",
        safe="",
    )

    encoded_password = quote(
        raw_password or "",
        safe="",
    )

    return f"{encoded_username}:{encoded_password}@"
