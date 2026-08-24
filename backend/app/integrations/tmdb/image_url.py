"""TMDB image URL construction utilities.

TMDB media payloads do not normally return complete image URLs.

Instead, fields such as:

    poster_path
    backdrop_path
    profile_path
    logo_path

contain relative file paths such as:

    /abcdef.jpg

A complete TMDB image URL is composed from:

    base URL
        +
    image size
        +
    file path

For example:

    /abcdef.jpg

can become:

    https://image.tmdb.org/t/p/w500/abcdef.jpg

Cineara's backend owns this transformation.

Flutter must never need to know:

- TMDB's image host;
- TMDB image-size identifiers;
- how paths are normalized;
- how missing TMDB images are represented.

The integration/mapping layer should therefore convert raw TMDB paths into
complete URLs before returning Cineara API responses.

Example
-------

Raw TMDB search result:

    poster_path = "/abcdef.jpg"

Cineara mapping:

    image_url = poster_url(result.poster_path)

Flutter receives:

    {
        "image_url": "https://image.tmdb.org/t/p/w500/abcdef.jpg"
    }

instead of:

    {
        "poster_path": "/abcdef.jpg"
    }
"""

from __future__ import annotations

from dataclasses import dataclass

# =============================================================================
# Default TMDB image configuration
# =============================================================================
#
# TMDB exposes image configuration through its configuration endpoint.
#
# These defaults make Cineara's integration immediately usable while keeping
# the builder configurable so the values can later be populated from TMDB
# configuration if desired.
# =============================================================================


DEFAULT_TMDB_IMAGE_BASE_URL = "https://image.tmdb.org/t/p"

DEFAULT_POSTER_SIZE = "w500"
DEFAULT_PROFILE_SIZE = "w185"
DEFAULT_BACKDROP_SIZE = "w1280"

ORIGINAL_IMAGE_SIZE = "original"


# =============================================================================
# Image URL builder
# =============================================================================


@dataclass(frozen=True, slots=True)
class TmdbImageUrlBuilder:
    """Build complete TMDB image URLs.

    Parameters
    ----------
    base_url:
        Base TMDB image URL.

    poster_size:
        Default image size used for poster artwork.

    profile_size:
        Default image size used for person/profile artwork.

    backdrop_size:
        Default image size used for backdrop artwork.

    Notes
    -----
    Raw TMDB paths remain completely separate from Cineara's public API.

    For example:

        builder.poster("/abc.jpg")

    returns a complete URL while:

        builder.poster(None)

    returns ``None``.

    The class is immutable and safe to reuse throughout the application.
    """

    base_url: str = DEFAULT_TMDB_IMAGE_BASE_URL

    poster_size: str = DEFAULT_POSTER_SIZE
    profile_size: str = DEFAULT_PROFILE_SIZE
    backdrop_size: str = DEFAULT_BACKDROP_SIZE

    # =========================================================================
    # Generic builder
    # =========================================================================

    def build(
        self,
        path: str | None,
        *,
        size: str,
    ) -> str | None:
        """Build a complete TMDB image URL.

        Parameters
        ----------
        path:
            Raw TMDB image path.

            Examples:

                "/abcdef.jpg"
                "abcdef.jpg"

            ``None`` and blank strings produce ``None``.

        size:
            TMDB image-size identifier.

            Examples:

                "w185"
                "w500"
                "w1280"
                "original"

        Returns
        -------
        str | None
            Complete image URL, or ``None`` if no usable image path exists.

        Raises
        ------
        ValueError
            If the image size or configured base URL is invalid.
        """

        normalized_path = _normalize_image_path(path)

        if normalized_path is None:
            return None

        normalized_size = _normalize_image_size(size)

        normalized_base_url = _normalize_base_url(
            self.base_url,
        )

        return f"{normalized_base_url}/{normalized_size}/{normalized_path}"

    # =========================================================================
    # Poster
    # =========================================================================

    def poster(
        self,
        path: str | None,
    ) -> str | None:
        """Build a poster image URL.

        Intended for:

            movie.poster_path
            tv.poster_path
            season.poster_path
            collection.poster_path

        Example
        -------

            builder.poster("/abcdef.jpg")

        returns:

            https://image.tmdb.org/t/p/w500/abcdef.jpg
        """

        return self.build(
            path,
            size=self.poster_size,
        )

    # =========================================================================
    # Profile
    # =========================================================================

    def profile(
        self,
        path: str | None,
    ) -> str | None:
        """Build a person/profile image URL.

        Intended for:

            person.profile_path

        Example
        -------

            builder.profile("/abcdef.jpg")

        returns a complete profile-image URL.
        """

        return self.build(
            path,
            size=self.profile_size,
        )

    # =========================================================================
    # Backdrop
    # =========================================================================

    def backdrop(
        self,
        path: str | None,
    ) -> str | None:
        """Build a backdrop image URL.

        Intended for:

            movie.backdrop_path
            tv.backdrop_path
            collection.backdrop_path

        Example
        -------

            builder.backdrop("/abcdef.jpg")

        returns a complete backdrop-image URL.
        """

        return self.build(
            path,
            size=self.backdrop_size,
        )

    # =========================================================================
    # Original
    # =========================================================================

    def original(
        self,
        path: str | None,
    ) -> str | None:
        """Build an original-resolution TMDB image URL.

        This should be used selectively because original artwork can be much
        larger than the resized variants.

        It is useful later for:

            image galleries;
            fullscreen artwork;
            original logos where required.
        """

        return self.build(
            path,
            size=ORIGINAL_IMAGE_SIZE,
        )

    # =========================================================================
    # Arbitrary size
    # =========================================================================

    def sized(
        self,
        path: str | None,
        *,
        size: str,
    ) -> str | None:
        """Build an image URL using an explicitly requested TMDB size.

        This is useful when a future Cineara surface needs a different image
        resolution without adding another specialized method.
        """

        return self.build(
            path,
            size=size,
        )


# =============================================================================
# Shared default builder
# =============================================================================
#
# Most Cineara mapping code does not need a custom builder.
#
# Keep one immutable module-level builder for those common cases.
# =============================================================================


_default_builder = TmdbImageUrlBuilder()


# =============================================================================
# Convenience functions
# =============================================================================


def poster_url(
    path: str | None,
) -> str | None:
    """Return a complete URL for a TMDB poster path.

    Example
    -------

        poster_url("/abcdef.jpg")

    returns:

        https://image.tmdb.org/t/p/w500/abcdef.jpg
    """

    return _default_builder.poster(path)


def profile_url(
    path: str | None,
) -> str | None:
    """Return a complete URL for a TMDB person profile path."""

    return _default_builder.profile(path)


def backdrop_url(
    path: str | None,
) -> str | None:
    """Return a complete URL for a TMDB backdrop path."""

    return _default_builder.backdrop(path)


def original_image_url(
    path: str | None,
) -> str | None:
    """Return a complete URL for original-resolution TMDB artwork."""

    return _default_builder.original(path)


def image_url(
    path: str | None,
    *,
    size: str,
) -> str | None:
    """Return a complete TMDB image URL for an explicit size.

    Prefer the semantic helpers:

        poster_url()
        profile_url()
        backdrop_url()

    whenever possible.

    Use this generic helper for less common artwork sizes.
    """

    return _default_builder.sized(
        path,
        size=size,
    )


# =============================================================================
# Normalization helpers
# =============================================================================


def _normalize_image_path(
    path: str | None,
) -> str | None:
    """Normalize a raw TMDB image path.

    TMDB generally returns paths beginning with ``/``:

        /abcdef.jpg

    The leading slash is removed because the builder inserts separators
    itself.

    Missing and blank values return ``None``.

    Complete external URLs are deliberately rejected rather than propagated.
    This function exists specifically for TMDB image paths and should not
    become a generic arbitrary-image proxy.
    """

    if path is None:
        return None

    if not isinstance(path, str):
        return None

    normalized = path.strip()

    if not normalized:
        return None

    # -------------------------------------------------------------------------
    # This utility should only receive raw TMDB paths.
    #
    # Do not silently propagate arbitrary external URLs.
    # -------------------------------------------------------------------------

    lowered = normalized.lower()

    if lowered.startswith(
        (
            "http://",
            "https://",
            "//",
        )
    ):
        return None

    # Remove any number of accidental leading slashes.
    normalized = normalized.lstrip("/")

    if not normalized:
        return None

    return normalized


def _normalize_image_size(
    size: str,
) -> str:
    """Normalize and validate a TMDB image-size identifier."""

    if not isinstance(size, str):
        raise ValueError("TMDB image size must be a non-empty string.")

    normalized = size.strip().strip("/")

    if not normalized:
        raise ValueError("TMDB image size must be a non-empty string.")

    # Prevent malformed values from changing the URL path structure.
    if "/" in normalized:
        raise ValueError("TMDB image size must not contain '/'.")

    if "://" in normalized:
        raise ValueError(
            "TMDB image size must be a size identifier, not a URL."
        )

    return normalized


def _normalize_base_url(
    base_url: str,
) -> str:
    """Normalize and validate the configured TMDB image base URL."""

    if not isinstance(base_url, str):
        raise ValueError("TMDB image base URL must be a non-empty HTTPS URL.")

    normalized = base_url.strip().rstrip("/")

    if not normalized:
        raise ValueError("TMDB image base URL must be a non-empty HTTPS URL.")

    if not normalized.lower().startswith("https://"):
        raise ValueError("TMDB image base URL must use HTTPS.")

    return normalized


# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "DEFAULT_BACKDROP_SIZE",
    "DEFAULT_POSTER_SIZE",
    "DEFAULT_PROFILE_SIZE",
    "DEFAULT_TMDB_IMAGE_BASE_URL",
    "ORIGINAL_IMAGE_SIZE",
    "TmdbImageUrlBuilder",
    "backdrop_url",
    "image_url",
    "original_image_url",
    "poster_url",
    "profile_url",
]
