"""Deterministic cache-key construction for Cineara Search.

This module centralizes versioned cache keys used by the Search service.

Search queries are hashed before being embedded in keys. This keeps Redis keys
bounded and avoids storing arbitrary user-entered query text directly in key
names.

Cache keys include only parameters that can change the corresponding response.

This module performs no:

- cache I/O;
- network requests;
- Search orchestration;
- serialization.
"""

from __future__ import annotations

from hashlib import blake2b
from typing import Final

from .schemas import SearchCategory

# =============================================================================
# Namespace
# =============================================================================


_SEARCH_CACHE_NAMESPACE: Final = "search"
_SEARCH_CACHE_VERSION: Final = "v1"


# =============================================================================
# Public builders
# =============================================================================


def search_page_cache_key(
    *,
    query: str,
    category: SearchCategory,
    page: int,
    language: str | None,
    include_adult: bool,
    region: str | None,
) -> str:
    """Build the cache key for one dedicated paginated Search request."""

    normalized_category = _normalize_category(
        category,
    )

    normalized_page = _normalize_page(
        page,
    )

    query_digest = _query_digest(
        query,
    )

    dimensions: list[str] = [
        _SEARCH_CACHE_NAMESPACE,
        _SEARCH_CACHE_VERSION,
        "page",
        normalized_category.value,
        f"q={query_digest}",
        f"p={normalized_page}",
    ]

    if normalized_category in {
        SearchCategory.MOVIES,
        SearchCategory.TV,
        SearchCategory.PEOPLE,
        SearchCategory.COLLECTIONS,
    }:
        dimensions.append(f"lang={_normalize_language(language)}")
        dimensions.append(f"adult={_bool_token(include_adult)}")

    if normalized_category in {
        SearchCategory.MOVIES,
        SearchCategory.COLLECTIONS,
    }:
        dimensions.append(f"region={_normalize_region(region)}")

    return ":".join(
        dimensions,
    )


def search_overview_cache_key(
    *,
    query: str,
    language: str | None,
    include_adult: bool,
    region: str | None,
    section_limit: int,
) -> str:
    """Build the cache key for Cineara's grouped Search overview."""

    return ":".join(
        (
            _SEARCH_CACHE_NAMESPACE,
            _SEARCH_CACHE_VERSION,
            "overview",
            f"q={_query_digest(query)}",
            f"lang={_normalize_language(language)}",
            f"adult={_bool_token(include_adult)}",
            f"region={_normalize_region(region)}",
            f"limit={
                _normalize_positive_int(section_limit, name='section_limit')
            }",
        )
    )


def search_landing_cache_key(
    *,
    language: str | None,
    include_adult: bool,
    time_window: str,
    limit: int,
) -> str:
    """Build the cache key for Search landing content."""

    normalized_time_window = time_window.strip().lower()

    if normalized_time_window not in {
        "day",
        "week",
    }:
        raise ValueError("time_window must be either 'day' or 'week'.")

    return ":".join(
        (
            _SEARCH_CACHE_NAMESPACE,
            _SEARCH_CACHE_VERSION,
            "landing",
            f"lang={_normalize_language(language)}",
            f"adult={_bool_token(include_adult)}",
            f"window={normalized_time_window}",
            f"limit={_normalize_positive_int(limit, name='limit')}",
        )
    )


# =============================================================================
# Query normalization
# =============================================================================


def normalize_search_query(
    value: str,
) -> str:
    """Normalize user Search text consistently for service/cache use."""

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("query must be a string.")

    normalized = " ".join(
        value.split(),
    )

    if not normalized:
        raise ValueError("query must not be blank.")

    return normalized


def _query_digest(
    value: str,
) -> str:
    """Return a stable bounded digest for normalized Search text."""

    normalized = normalize_search_query(
        value,
    ).casefold()

    return blake2b(
        normalized.encode(
            "utf-8",
        ),
        digest_size=16,
    ).hexdigest()


# =============================================================================
# Dimension normalization
# =============================================================================


def _normalize_category(
    value: SearchCategory,
) -> SearchCategory:
    if not isinstance(
        value,
        SearchCategory,
    ):
        raise TypeError("category must be a SearchCategory.")

    return value


def _normalize_page(
    value: int,
) -> int:
    return _normalize_positive_int(
        value,
        name="page",
    )


def _normalize_positive_int(
    value: int,
    *,
    name: str,
) -> int:
    if isinstance(
        value,
        bool,
    ) or not isinstance(
        value,
        int,
    ):
        raise TypeError(f"{name} must be an integer.")

    if value < 1:
        raise ValueError(f"{name} must be greater than or equal to 1.")

    return value


def _normalize_language(
    value: str | None,
) -> str:
    if value is None:
        return "-"

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("language must be a string or None.")

    normalized = (
        value.strip()
        .lower()
        .replace(
            "_",
            "-",
        )
    )

    return normalized or "-"


def _normalize_region(
    value: str | None,
) -> str:
    if value is None:
        return "-"

    if not isinstance(
        value,
        str,
    ):
        raise TypeError("region must be a string or None.")

    normalized = value.strip().upper()

    return normalized or "-"


def _bool_token(
    value: bool,
) -> str:
    if not isinstance(
        value,
        bool,
    ):
        raise TypeError("Boolean cache dimensions must be bool values.")

    return "1" if value else "0"
