"""Configuration and infrastructure readiness checks."""

from __future__ import annotations

import asyncio
from functools import lru_cache
from typing import Literal

from pydantic import BaseModel, Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

EnvironmentName = Literal["development", "staging", "production", "test"]


class Settings(BaseSettings):
    """Validated runtime configuration loaded from ``CINEARA_*`` variables."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        env_prefix="CINEARA_",
        case_sensitive=False,
        extra="ignore",
    )

    environment: Literal["development", "staging", "production", "test"] = (
        "development"
    )
    debug: bool = False
    log_level: str = "INFO"

    api_host: str = "0.0.0.0"
    api_port: int = Field(default=8000, ge=1, le=65535)

    postgres_host: str = "localhost"
    postgres_port: int = Field(default=5432, ge=1, le=65535)
    postgres_database: str = "cineara"
    postgres_user: str = "cineara"
    postgres_password: SecretStr = SecretStr("cineara_dev_password")

    redis_host: str = "localhost"
    redis_port: int = Field(default=6379, ge=1, le=65535)
    dependency_timeout_seconds: float = Field(default=1.0, gt=0.0, le=30.0)


class DependencyStatus(BaseModel):
    """Availability of infrastructure required to serve normal requests."""

    postgres: bool
    redis: bool

    @property
    def ready(self) -> bool:
        """Return whether every required dependency is reachable."""
        return self.postgres and self.redis


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return one cached settings instance for the current process."""
    return Settings()


async def _check_tcp_service(
    host: str, port: int, timeout_seconds: float
) -> bool:
    """Check whether a TCP service is reachable within a timeout.

    Args:
        host: Hostname or IP address of the TCP service.
        port: TCP port number to connect to.
        timeout_seconds: Maximum number of seconds to wait for the connection.

    Returns:
        ``True`` if the connection is opened successfully; otherwise,
            ``False``.
    """
    writer: asyncio.StreamWriter | None = None
    try:
        _, writer = await asyncio.wait_for(
            asyncio.open_connection(host=host, port=port),
            timeout=timeout_seconds,
        )
        return True
    except (OSError, TimeoutError):
        return False
    finally:
        if writer is not None:
            writer.close()
            await writer.wait_closed()


async def _check_redis(
    host: str,
    port: int,
    timeout_seconds: float,
) -> bool:
    """Send a Redis PING command and require a PONG response.

    Args:
        host: Redis server hostname or IP address.
        port: Redis server TCP port.
        timeout_seconds: Maximum number of seconds allowed for the check.

    Returns:
        ``True`` if Redis returns ``PONG``; otherwise, ``False``.
    """
    writer: asyncio.StreamWriter | None = None

    try:
        async with asyncio.timeout(timeout_seconds):
            reader, connection_writer = await asyncio.open_connection(
                host=host,
                port=port,
            )
            writer = connection_writer
            connection_writer.write(b"*1\r\n$4\r\nPING\r\n")
            await connection_writer.drain()
            response = await reader.readline()

        return response == b"+PONG\r\n"

    except (OSError, TimeoutError):
        return False

    finally:
        if writer is not None:
            writer.close()
            await writer.wait_closed()


async def get_dependency_status() -> DependencyStatus:
    """Check PostgreSQL and Redis concurrently for the readiness endpoint."""
    settings = get_settings()
    postgres_ready, redis_ready = await asyncio.gather(
        _check_tcp_service(
            settings.postgres_host,
            settings.postgres_port,
            settings.dependency_timeout_seconds,
        ),
        _check_redis(
            settings.redis_host,
            settings.redis_port,
            settings.dependency_timeout_seconds,
        ),
    )
    return DependencyStatus(postgres=postgres_ready, redis=redis_ready)
