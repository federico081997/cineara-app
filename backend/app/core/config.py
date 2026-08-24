"""Application settings and environment config for the Cineara backend."""

from __future__ import annotations

from functools import lru_cache
from typing import Literal

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Validated runtime configuration loaded from ``CINEARA_*`` variables.

    Environment variables use the ``CINEARA_`` prefix.

    Examples
    --------

    TMDB:

        CINEARA_TMDB_ACCESS_TOKEN=...
        CINEARA_TMDB_BASE_URL=https://api.themoviedb.org/3
        CINEARA_TMDB_LANGUAGE=en-US
        CINEARA_TMDB_REQUEST_TIMEOUT_SECONDS=10

    Search:

        CINEARA_SEARCH_MIN_QUERY_LENGTH=2
        CINEARA_SEARCH_CACHE_TTL_SECONDS=300
        CINEARA_MOVIE_METADATA_CACHE_TTL_SECONDS=86400
        CINEARA_TMDB_ENRICHMENT_CONCURRENCY=4

    PostgreSQL:

        CINEARA_POSTGRES_HOST=localhost
        CINEARA_POSTGRES_PORT=5432

    Redis:

        CINEARA_REDIS_HOST=localhost
        CINEARA_REDIS_PORT=6379
    """

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

    environment: Literal[
        "development",
        "staging",
        "production",
        "test",
    ] = "development"

    debug: bool = False

    log_level: str = "INFO"

    # =========================================================================
    # API
    # =========================================================================

    api_host: str = "0.0.0.0"

    api_port: int = Field(
        default=8000,
        ge=1,
        le=65535,
    )

    # =========================================================================
    # TMDB
    # =========================================================================
    #
    # ``tmdb_access_token`` is the canonical Cineara setting.
    #
    # The legacy name:
    #
    #     CINEARA_TMDB_READ_ACCESS_TOKEN
    #
    # remains accepted temporarily so an existing development .env file does
    # not need to be changed immediately.
    # =========================================================================

    tmdb_access_token: SecretStr

    tmdb_base_url: str = "https://api.themoviedb.org/3"

    tmdb_language: str = "en-US"

    tmdb_request_timeout_seconds: float = Field(
        default=10.0,
        gt=0.0,
        le=60.0,
    )

    # =========================================================================
    # Search
    # =========================================================================
    #
    # These values belong in configuration rather than being hard-coded inside
    # modules/search.py.
    #
    # Search will use:
    #
    #     search_min_query_length
    #
    # before requesting TMDB.
    #
    # Search-result pages use:
    #
    #     search_cache_ttl_seconds
    #
    # while enriched movie metadata uses the substantially longer:
    #
    #     movie_metadata_cache_ttl_seconds
    #
    # because production-country metadata changes extremely rarely.
    # =========================================================================

    search_min_query_length: int = Field(
        default=2,
        ge=1,
        le=20,
    )

    search_cache_ttl_seconds: int = Field(
        default=300,
        ge=1,
        le=86_400,
    )

    movie_metadata_cache_ttl_seconds: int = Field(
        default=86_400,
        ge=60,
        le=2_592_000,
    )

    tmdb_enrichment_concurrency: int = Field(
        default=4,
        ge=1,
        le=20,
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

    # =========================================================================
    # Infrastructure / dependency health checks
    # =========================================================================

    dependency_timeout_seconds: float = Field(
        default=1.0,
        gt=0.0,
        le=30.0,
    )

    # =========================================================================
    # Content policy
    # =========================================================================

    include_adult_content: bool = False

    include_mature_content: bool = True

    # =========================================================================
    # Backwards-compatible properties
    # =========================================================================

    @property
    def tmdb_read_access_token(self) -> SecretStr:
        """Return the TMDB access token using the previous field name.

        This compatibility property can be removed once all existing Cineara
        code has migrated from:

            settings.tmdb_read_access_token

        to:

            settings.tmdb_access_token
        """

        return self.tmdb_access_token


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return one cached settings instance for the current process."""

    return Settings()


__all__ = [
    "Settings",
    "get_settings",
]
