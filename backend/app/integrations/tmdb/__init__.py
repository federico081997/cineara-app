"""Public exports for Cineara's TMDB integration.

This package provides the stable entry points used by application and feature
layers when interacting with TMDB.

The package root intentionally exposes only integration-level APIs that are
useful outside the internal TMDB implementation:

- the high-level ``TmdbClient`` facade;
- shared TMDB configuration defaults;
- the TMDB transport exception hierarchy;
- image URL construction utilities.

Raw transport models and endpoint-group classes remain available from their
respective subpackages but are not re-exported here. Keeping the package root
small avoids coupling application code to internal integration structure.

Importing this package performs no network requests and creates no client
instances.
"""

from __future__ import annotations

from .client import TmdbClient
from .exceptions import (
    TmdbClientClosedError,
    TmdbClientError,
    TmdbHttpError,
    TmdbRequestError,
    TmdbResponseError,
    TmdbTimeoutError,
)
from .image_url import (
    DEFAULT_BACKDROP_SIZE,
    DEFAULT_LOGO_SIZE,
    DEFAULT_POSTER_SIZE,
    DEFAULT_PROFILE_SIZE,
    DEFAULT_STILL_SIZE,
    ORIGINAL_IMAGE_SIZE,
    TMDB_IMAGE_BASE_URL,
    TmdbImageUrlBuilder,
    backdrop_url,
    image_url,
    logo_url,
    original_image_url,
    poster_url,
    profile_url,
    still_url,
)

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "DEFAULT_BACKDROP_SIZE",
    "DEFAULT_LOGO_SIZE",
    "DEFAULT_POSTER_SIZE",
    "DEFAULT_PROFILE_SIZE",
    "DEFAULT_STILL_SIZE",
    "ORIGINAL_IMAGE_SIZE",
    "TMDB_IMAGE_BASE_URL",
    "TmdbClient",
    "TmdbClientClosedError",
    "TmdbClientError",
    "TmdbHttpError",
    "TmdbImageUrlBuilder",
    "TmdbRequestError",
    "TmdbResponseError",
    "TmdbTimeoutError",
    "backdrop_url",
    "image_url",
    "logo_url",
    "original_image_url",
    "poster_url",
    "profile_url",
    "still_url",
]
