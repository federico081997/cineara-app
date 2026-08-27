"""TMDB image URL construction utilities.

This module converts raw TMDB image paths into complete HTTPS image URLs.

TMDB transport models intentionally keep artwork fields such as
``poster_path``, ``backdrop_path``, ``profile_path``, ``logo_path``, and
``still_path`` as raw provider paths. URL construction is centralized here so
the rest of the integration layer does not duplicate image-host or size logic.

This module owns:

- TMDB image base-URL normalization;
- image-size token validation;
- raw image-path validation;
- complete image URL construction;
- resource-oriented convenience helpers.

It does not own:

- HTTP requests;
- TMDB configuration retrieval;
- caching;
- image preloading;
- fallback artwork;
- Cineara presentation logic;
- media classification;
- persistence;
- user preferences.

The utilities are deterministic and perform no network operations.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Final
from urllib.parse import urlsplit

# =============================================================================
# Defaults
# =============================================================================


TMDB_IMAGE_BASE_URL: Final = "https://image.tmdb.org/t/p"

DEFAULT_POSTER_SIZE: Final = "w500"
DEFAULT_PROFILE_SIZE: Final = "w185"
DEFAULT_BACKDROP_SIZE: Final = "w1280"
DEFAULT_LOGO_SIZE: Final = "w300"
DEFAULT_STILL_SIZE: Final = "w300"

ORIGINAL_IMAGE_SIZE: Final = "original"


# =============================================================================
# Builder
# =============================================================================


@dataclass(
    frozen=True,
    slots=True,
)
class TmdbImageUrlBuilder:
    """Immutable builder for complete TMDB image URLs."""

    base_url: str = TMDB_IMAGE_BASE_URL

    def __post_init__(self) -> None:
        """Normalize and validate the configured image base URL."""

        object.__setattr__(
            self,
            "base_url",
            _normalize_base_url(
                self.base_url,
            ),
        )

    # =========================================================================
    # Generic construction
    # =========================================================================

    def build(
        self,
        path: str | None,
        *,
        size: str,
    ) -> str | None:
        """Build a complete TMDB image URL."""

        normalized_path = _normalize_image_path(
            path,
        )

        if normalized_path is None:
            return None

        normalized_size = _normalize_size(
            size,
        )

        return f"{self.base_url}/{normalized_size}{normalized_path}"

    # =========================================================================
    # Resource-oriented helpers
    # =========================================================================

    def poster(
        self,
        path: str | None,
        *,
        size: str = DEFAULT_POSTER_SIZE,
    ) -> str | None:
        """Build a complete TMDB poster URL."""

        return self.build(
            path,
            size=size,
        )

    def profile(
        self,
        path: str | None,
        *,
        size: str = DEFAULT_PROFILE_SIZE,
    ) -> str | None:
        """Build a complete TMDB profile-image URL."""

        return self.build(
            path,
            size=size,
        )

    def backdrop(
        self,
        path: str | None,
        *,
        size: str = DEFAULT_BACKDROP_SIZE,
    ) -> str | None:
        """Build a complete TMDB backdrop URL."""

        return self.build(
            path,
            size=size,
        )

    def logo(
        self,
        path: str | None,
        *,
        size: str = DEFAULT_LOGO_SIZE,
    ) -> str | None:
        """Build a complete TMDB logo URL."""

        return self.build(
            path,
            size=size,
        )

    def still(
        self,
        path: str | None,
        *,
        size: str = DEFAULT_STILL_SIZE,
    ) -> str | None:
        """Build a complete TMDB episode-still URL."""

        return self.build(
            path,
            size=size,
        )

    def original(
        self,
        path: str | None,
    ) -> str | None:
        """Build a complete original-resolution TMDB image URL."""

        return self.build(
            path,
            size=ORIGINAL_IMAGE_SIZE,
        )

    def sized(
        self,
        path: str | None,
        *,
        size: str,
    ) -> str | None:
        """Build a complete TMDB image URL using an explicit size token."""

        return self.build(
            path,
            size=size,
        )


# =============================================================================
# Base-URL validation
# =============================================================================


def _normalize_base_url(
    value: str,
) -> str:
    """Normalize and validate a TMDB image base URL."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("base_url must be a string.")

    normalized = value.strip().rstrip("/")

    if not normalized:
        raise ValueError("base_url must not be blank.")

    parsed = urlsplit(
        normalized,
    )

    if parsed.scheme.lower() != "https":
        raise ValueError("base_url must use HTTPS.")

    if not parsed.netloc:
        raise ValueError("base_url must contain a host.")

    if parsed.username is not None or parsed.password is not None:
        raise ValueError("base_url must not contain credentials.")

    if parsed.query:
        raise ValueError("base_url must not contain a query string.")

    if parsed.fragment:
        raise ValueError("base_url must not contain a fragment.")

    return normalized


# =============================================================================
# Image-path validation
# =============================================================================


def _normalize_image_path(
    value: str | None,
) -> str | None:
    """Normalize and validate a raw TMDB image path."""

    if value is None:
        return None

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("image path must be a string or None.")

    normalized = value.strip()

    if not normalized:
        return None

    if "\\" in normalized:
        raise ValueError("image path must not contain backslashes.")

    parsed = urlsplit(
        normalized,
    )

    if parsed.scheme or parsed.netloc:
        raise ValueError(
            "image path must be a raw TMDB path, not a complete URL."
        )

    if parsed.query:
        raise ValueError("image path must not contain a query string.")

    if parsed.fragment:
        raise ValueError("image path must not contain a fragment.")

    if not normalized.startswith("/"):
        normalized = f"/{normalized}"

    path_segments = normalized.split("/")

    if any(
        segment
        in {
            ".",
            "..",
        }
        for segment in path_segments
    ):
        raise ValueError(
            "image path must not contain path traversal segments."
        )

    if normalized == "/":
        return None

    return normalized


# =============================================================================
# Image-size validation
# =============================================================================


def _normalize_size(
    value: str,
) -> str:
    """Normalize and validate a TMDB image-size token."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("size must be a string.")

    normalized = value.strip().lower()

    if not normalized:
        raise ValueError("size must not be blank.")

    if normalized == ORIGINAL_IMAGE_SIZE:
        return normalized

    if normalized[0] not in {
        "w",
        "h",
    }:
        raise ValueError("size must be 'original' or begin with 'w' or 'h'.")

    numeric_part = normalized[1:]

    if (
        not numeric_part
        or not numeric_part.isascii()
        or not numeric_part.isdigit()
    ):
        raise ValueError("size must contain a positive integer dimension.")

    if (
        int(
            numeric_part,
        )
        <= 0
    ):
        raise ValueError("size dimension must be greater than 0.")

    return normalized


# =============================================================================
# Default builder
# =============================================================================


_default_builder: Final = TmdbImageUrlBuilder()


# =============================================================================
# Convenience functions
# =============================================================================


def image_url(
    path: str | None,
    *,
    size: str,
) -> str | None:
    """Build a TMDB image URL using the default image builder."""

    return _default_builder.build(
        path,
        size=size,
    )


def poster_url(
    path: str | None,
    *,
    size: str = DEFAULT_POSTER_SIZE,
) -> str | None:
    """Build a TMDB poster URL using the default image builder."""

    return _default_builder.poster(
        path,
        size=size,
    )


def profile_url(
    path: str | None,
    *,
    size: str = DEFAULT_PROFILE_SIZE,
) -> str | None:
    """Build a TMDB profile-image URL using the default image builder."""

    return _default_builder.profile(
        path,
        size=size,
    )


def backdrop_url(
    path: str | None,
    *,
    size: str = DEFAULT_BACKDROP_SIZE,
) -> str | None:
    """Build a TMDB backdrop URL using the default image builder."""

    return _default_builder.backdrop(
        path,
        size=size,
    )


def logo_url(
    path: str | None,
    *,
    size: str = DEFAULT_LOGO_SIZE,
) -> str | None:
    """Build a TMDB logo URL using the default image builder."""

    return _default_builder.logo(
        path,
        size=size,
    )


def still_url(
    path: str | None,
    *,
    size: str = DEFAULT_STILL_SIZE,
) -> str | None:
    """Build a TMDB episode-still URL using the default image builder."""

    return _default_builder.still(
        path,
        size=size,
    )


def original_image_url(
    path: str | None,
) -> str | None:
    """Build an original-resolution TMDB image URL."""

    return _default_builder.original(
        path,
    )
