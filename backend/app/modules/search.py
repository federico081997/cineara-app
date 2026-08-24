"""Cineara catalogue search endpoint.

The module owns the Search vertical slice:

    Flutter
        ↓
    GET /api/v1/search
        ↓
    normalized search-page cache
        ↓ miss
    TMDB Search
        ↓
    normalized source page
        ↓
    Cineara media classification
        ↓
    SearchPage response

Movies and TV series expose normalized genres. TV series can additionally
expose one cultural/editorial classification such as Anime, K-Drama, or C-Drama
when the TMDB search metadata supports it.
"""

from __future__ import annotations

import logging
from collections.abc import Iterable
from enum import StrEnum
from typing import Annotated
from urllib.parse import quote

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    Request,
    status,
)
from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    PositiveInt,
    ValidationError,
)

from app.catalogue.media_classification import (
    MediaClassification,
    MediaFormat,
    MediaType,
    SpecialClassification,
    classify_media,
)
from app.core.config import Settings, get_settings
from app.integrations.redis.cache import Cache, CacheError
from app.integrations.tmdb.client import (
    TmdbClient,
    TmdbClientError,
    TmdbTimeoutError,
)
from app.integrations.tmdb.image_url import poster_url, profile_url
from app.integrations.tmdb.models.search import (
    TmdbMovieSearchResult,
    TmdbPersonSearchResult,
    TmdbTvSearchResult,
)

logger = logging.getLogger(__name__)

# =============================================================================
# Search-source cache
# =============================================================================


_SEARCH_SOURCE_CACHE_VERSION = "v1"

# =============================================================================
# FastAPI router / selector
# =============================================================================


router = APIRouter(
    prefix="/search",
    tags=["Search"],
)


class SearchType(StrEnum):
    """Available Cineara search selectors."""

    ALL = "all"
    MOVIES = "movies"
    TV = "tv"
    PEOPLE = "people"


# =============================================================================
# Public response models
# =============================================================================


class SearchResult(BaseModel):
    """One normalized Cineara search result.

    Movie example:
        Movie · 2016 · Animation · Romance

    TV example with a special classification:
        Series · Anime · 2023 · Animation · Sci-Fi & Fantasy

    TV example without a special classification:
        Series · 2024 · Comedy · Crime
    """

    model_config = ConfigDict(extra="forbid")

    id: PositiveInt
    media_type: MediaType
    media_format: MediaFormat | None = None

    title: str
    image_url: str | None = None

    year: int | None = Field(
        default=None,
        ge=1000,
        le=9999,
    )

    genres: list[str] | None = None
    special_classification: SpecialClassification | None = None

    known_for_department: str | None = None


class SearchPage(BaseModel):
    """Paginated Cineara search response."""

    model_config = ConfigDict(extra="forbid")

    query: str
    search_type: SearchType

    page: int = Field(ge=1)
    total_pages: int = Field(ge=0)
    total_results: int = Field(ge=0)

    results: list[SearchResult] = Field(default_factory=list)


# =============================================================================
# Internal normalized search-source models
# =============================================================================


class _SearchSourceItem(BaseModel):
    """Compact cacheable representation of one TMDB search result."""

    model_config = ConfigDict(extra="forbid")

    id: PositiveInt
    media_type: MediaType

    title: str
    image_path: str | None = None
    year: int | None = Field(
        default=None,
        ge=1000,
        le=9999,
    )

    genre_ids: list[int] = Field(default_factory=list)
    original_language: str | None = None
    origin_country_codes: list[str] = Field(default_factory=list)

    known_for_department: str | None = None


class _SearchSourcePage(BaseModel):
    """Language-specific normalized TMDB search page cached by Cineara."""

    model_config = ConfigDict(extra="forbid")

    page: int = Field(ge=1)
    total_pages: int = Field(ge=0)
    total_results: int = Field(ge=0)

    results: list[_SearchSourceItem] = Field(default_factory=list)


type _RawSearchResult = (
    TmdbMovieSearchResult | TmdbTvSearchResult | TmdbPersonSearchResult
)


# =============================================================================
# FastAPI dependencies
# =============================================================================


def _get_tmdb_client(request: Request) -> TmdbClient:
    """Return the application-scoped TMDB client."""

    client = getattr(
        request.app.state,
        "tmdb_client",
        None,
    )

    if not isinstance(client, TmdbClient):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="TMDB integration is not available.",
        )

    return client


def _get_cache(request: Request) -> Cache:
    """Return the application-scoped cache."""

    cache = getattr(
        request.app.state,
        "cache",
        None,
    )

    if not isinstance(cache, Cache):
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Cache infrastructure is not available.",
        )

    return cache


SettingsDependency = Annotated[
    Settings,
    Depends(get_settings),
]

TmdbClientDependency = Annotated[
    TmdbClient,
    Depends(_get_tmdb_client),
]

CacheDependency = Annotated[
    Cache,
    Depends(_get_cache),
]


# =============================================================================
# GET /search
# =============================================================================


@router.get(
    "",
    response_model=SearchPage,
    response_model_exclude_none=True,
    summary="Search the Cineara catalogue",
)
async def search(
    query: Annotated[
        str,
        Query(
            description="Title or person name to search for.",
        ),
    ],
    settings: SettingsDependency,
    tmdb_client: TmdbClientDependency,
    cache: CacheDependency,
    search_type: Annotated[
        SearchType,
        Query(
            alias="type",
            description="Search category.",
        ),
    ] = SearchType.ALL,
    page: Annotated[
        int,
        Query(
            ge=1,
            description="Search result page.",
        ),
    ] = 1,
) -> SearchPage:
    """Search movies, TV programmes and people."""

    normalized_query = _normalize_search_query(query)

    _validate_search_query_length(
        normalized_query,
        minimum=settings.search_min_query_length,
    )

    language = settings.tmdb_language
    include_adult = settings.include_adult_content

    source_cache_key = _search_source_cache_key(
        search_type=search_type,
        language=language,
        include_adult=include_adult,
        query=normalized_query,
        page=page,
    )

    source_page = await _get_cached_search_source_page(
        cache,
        source_cache_key,
    )

    if source_page is None:
        try:
            source_page = await _fetch_search_source_page(
                tmdb_client=tmdb_client,
                query=normalized_query,
                search_type=search_type,
                page=page,
                language=language,
                include_adult=include_adult,
            )

        except TmdbTimeoutError as exc:
            logger.warning("TMDB Search request timed out.")

            raise HTTPException(
                status_code=status.HTTP_504_GATEWAY_TIMEOUT,
                detail="The catalogue service timed out.",
            ) from exc

        except TmdbClientError as exc:
            logger.warning("TMDB Search request failed.")

            raise HTTPException(
                status_code=status.HTTP_502_BAD_GATEWAY,
                detail="The catalogue service could not complete the search.",
            ) from exc

        await _set_cached_search_source_page(
            cache,
            source_cache_key,
            source_page,
            ttl_seconds=settings.search_cache_ttl_seconds,
        )

    return SearchPage(
        query=normalized_query,
        search_type=search_type,
        page=source_page.page,
        total_pages=source_page.total_pages,
        total_results=source_page.total_results,
        results=[_map_search_result(result) for result in source_page.results],
    )


# =============================================================================
# TMDB search dispatch + source normalization
# =============================================================================


async def _fetch_search_source_page(
    *,
    tmdb_client: TmdbClient,
    query: str,
    search_type: SearchType,
    page: int,
    language: str,
    include_adult: bool,
) -> _SearchSourcePage:
    """Fetch one TMDB search page and normalize it for caching."""

    raw_results: list[_RawSearchResult]

    if search_type is SearchType.ALL:
        multi_page = await tmdb_client.search_multi(
            query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        raw_results = list(multi_page.results)
        page_number = multi_page.page
        total_pages = multi_page.total_pages
        total_results = multi_page.total_results

    elif search_type is SearchType.MOVIES:
        movie_page = await tmdb_client.search_movies(
            query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        raw_results = list(movie_page.results)
        page_number = movie_page.page
        total_pages = movie_page.total_pages
        total_results = movie_page.total_results

    elif search_type is SearchType.TV:
        tv_page = await tmdb_client.search_tv(
            query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        raw_results = list(tv_page.results)
        page_number = tv_page.page
        total_pages = tv_page.total_pages
        total_results = tv_page.total_results

    elif search_type is SearchType.PEOPLE:
        people_page = await tmdb_client.search_people(
            query,
            page=page,
            language=language,
            include_adult=include_adult,
        )

        raw_results = list(people_page.results)
        page_number = people_page.page
        total_pages = people_page.total_pages
        total_results = people_page.total_results

    else:
        raise ValueError(f"Unsupported SearchType: {search_type!r}")

    return _SearchSourcePage(
        page=page_number,
        total_pages=total_pages,
        total_results=total_results,
        results=[_source_item_from_tmdb(result) for result in raw_results],
    )


def _source_item_from_tmdb(
    result: _RawSearchResult,
) -> _SearchSourceItem:
    """Normalize one TMDB search model into Cineara's source model."""

    if isinstance(result, TmdbMovieSearchResult):
        return _SearchSourceItem(
            id=result.id,
            media_type=MediaType.MOVIE,
            title=_prefer_title(
                result.title,
                result.original_title,
            ),
            image_path=_normalize_optional_text(result.poster_path),
            year=_extract_year(result.release_date),
            genre_ids=_normalize_genre_ids(result.genre_ids),
            original_language=None,
            origin_country_codes=[],
            known_for_department=None,
        )

    if isinstance(result, TmdbTvSearchResult):
        return _SearchSourceItem(
            id=result.id,
            media_type=MediaType.TV,
            title=_prefer_title(
                result.name,
                result.original_name,
            ),
            image_path=_normalize_optional_text(result.poster_path),
            year=_extract_year(result.first_air_date),
            genre_ids=_normalize_genre_ids(result.genre_ids),
            original_language=_normalize_optional_text(
                result.original_language,
            ),
            origin_country_codes=_normalize_country_codes(
                result.origin_country,
            ),
            known_for_department=None,
        )

    if isinstance(result, TmdbPersonSearchResult):
        return _SearchSourceItem(
            id=result.id,
            media_type=MediaType.PERSON,
            title=_prefer_title(
                result.name,
                result.original_name,
            ),
            image_path=_normalize_optional_text(result.profile_path),
            year=None,
            genre_ids=[],
            original_language=None,
            origin_country_codes=[],
            known_for_department=_normalize_optional_text(
                result.known_for_department,
            ),
        )

    raise TypeError(f"Unsupported TMDB search result: {type(result).__name__}")


# =============================================================================
# Final SearchResult mapping
# =============================================================================


def _map_search_result(
    result: _SearchSourceItem,
) -> SearchResult:
    """Map one normalized source item to the public search response."""

    if result.media_type is MediaType.MOVIE:
        return _map_movie(result)

    if result.media_type is MediaType.TV:
        return _map_tv(result)

    if result.media_type is MediaType.PERSON:
        return _map_person(result)

    raise TypeError(
        f"Unsupported normalized search result: {result.media_type!r}"
    )


def _map_movie(
    movie: _SearchSourceItem,
) -> SearchResult:
    """Map one movie search result."""

    classification = classify_media(
        MediaType.MOVIE,
        genre_ids=movie.genre_ids,
    )

    return _build_media_search_result(
        item=movie,
        classification=classification,
    )


def _map_tv(
    tv: _SearchSourceItem,
) -> SearchResult:
    """Map one TV search result."""

    classification = classify_media(
        MediaType.TV,
        genre_ids=tv.genre_ids,
        origin_country=tv.origin_country_codes,
        original_language=tv.original_language,
    )

    return _build_media_search_result(
        item=tv,
        classification=classification,
    )


def _build_media_search_result(
    *,
    item: _SearchSourceItem,
    classification: MediaClassification,
) -> SearchResult:
    """Build the common movie/TV search response."""

    return SearchResult(
        id=item.id,
        media_type=classification.media_type,
        media_format=classification.media_format,
        title=item.title,
        image_url=poster_url(item.image_path),
        year=item.year,
        genres=list(classification.genre_labels),
        special_classification=classification.special_classification,
        known_for_department=None,
    )


def _map_person(
    person: _SearchSourceItem,
) -> SearchResult:
    """Map one person search result."""

    return SearchResult(
        id=person.id,
        media_type=MediaType.PERSON,
        media_format=None,
        title=person.title,
        image_url=profile_url(person.image_path),
        year=None,
        genres=None,
        special_classification=None,
        known_for_department=person.known_for_department,
    )


# =============================================================================
# Search-source cache
# =============================================================================


async def _get_cached_search_source_page(
    cache: Cache,
    key: str,
) -> _SearchSourcePage | None:
    """Return a validated cached normalized search page."""

    try:
        payload = await cache.get_json(key)

    except CacheError:
        logger.warning(
            "Search-source cache read failed; continuing without cache."
        )
        return None

    if payload is None:
        return None

    try:
        return _SearchSourcePage.model_validate(payload)

    except ValidationError:
        logger.warning("Ignoring invalid cached search-source response.")
        await _delete_cache_best_effort(cache, key)
        return None


async def _set_cached_search_source_page(
    cache: Cache,
    key: str,
    page: _SearchSourcePage,
    *,
    ttl_seconds: int,
) -> None:
    """Cache one normalized TMDB search page."""

    try:
        await cache.set_json(
            key,
            page.model_dump(mode="json"),
            ttl_seconds=ttl_seconds,
        )

    except CacheError:
        logger.warning(
            "Search-source cache write failed; returning uncached response."
        )


async def _delete_cache_best_effort(
    cache: Cache,
    key: str,
) -> None:
    """Delete an invalid cache entry without failing the request."""

    try:
        await cache.delete(key)

    except CacheError:
        logger.warning("Failed to delete invalid search cache entry.")


# =============================================================================
# Cache key
# =============================================================================


def _search_source_cache_key(
    *,
    search_type: SearchType,
    language: str,
    include_adult: bool,
    query: str,
    page: int,
) -> str:
    """Build the cache key for one normalized search page."""

    encoded_language = _encode_cache_component(
        language,
        safe="-_",
    )
    encoded_query = _encode_cache_component(
        query,
        safe="",
    )
    content_mode = "adult" if include_adult else "standard"

    return (
        f"search-source:{_SEARCH_SOURCE_CACHE_VERSION}:"
        f"{content_mode}:{search_type.value}:{encoded_language}:"
        f"{encoded_query}:{page}"
    )


def _encode_cache_component(
    value: str,
    *,
    safe: str,
) -> str:
    """Encode one user/config-derived cache-key component."""

    return quote(
        value.strip(),
        safe=safe,
    )


# =============================================================================
# Input/source normalization
# =============================================================================


def _normalize_search_query(
    query: str,
) -> str:
    """Normalize whitespace in a user search query."""

    if not isinstance(query, str):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Search query must be a string.",
        )

    return " ".join(query.split())


def _validate_search_query_length(
    query: str,
    *,
    minimum: int,
) -> None:
    """Reject search queries shorter than the configured minimum."""

    if len(query) >= minimum:
        return

    raise HTTPException(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        detail=f"Search query must contain at least {minimum} characters.",
    )


def _extract_year(
    value: str | None,
) -> int | None:
    """Extract a four-digit year from a TMDB date string."""

    if value is None:
        return None

    normalized = value.strip()

    if len(normalized) < 4:
        return None

    year_text = normalized[:4]

    if not year_text.isdigit():
        return None

    year = int(year_text)

    if 1000 <= year <= 9999:
        return year

    return None


def _normalize_country_codes(
    values: Iterable[str] | None,
) -> list[str]:
    """Normalize country codes while preserving TMDB result order."""

    if values is None:
        return []

    if isinstance(values, str):
        iterable: Iterable[str] = (values,)
    else:
        iterable = values

    result: list[str] = []
    seen: set[str] = set()

    for value in iterable:
        if not isinstance(value, str):
            continue

        code = value.strip().upper()

        if len(code) != 2 or not code.isalpha() or code in seen:
            continue

        seen.add(code)
        result.append(code)

    return result


def _normalize_genre_ids(
    values: Iterable[int] | None,
) -> list[int]:
    """Normalize TMDB genre IDs while preserving result order."""

    if values is None:
        return []

    result: list[int] = []
    seen: set[int] = set()

    for value in values:
        if (
            isinstance(value, bool)
            or not isinstance(value, int)
            or value <= 0
            or value in seen
        ):
            continue

        seen.add(value)
        result.append(value)

    return result


def _prefer_title(
    primary: str | None,
    fallback: str | None,
) -> str:
    """Return a normalized primary title, then fallback, then Untitled."""

    primary_value = _normalize_optional_text(primary)

    if primary_value is not None:
        return primary_value

    fallback_value = _normalize_optional_text(fallback)

    if fallback_value is not None:
        return fallback_value

    return "Untitled"


def _normalize_optional_text(
    value: str | None,
) -> str | None:
    """Trim optional text and convert empty strings to None."""

    if value is None or not isinstance(value, str):
        return None

    normalized = value.strip()
    return normalized or None


__all__ = [
    "SearchPage",
    "SearchResult",
    "SearchType",
    "router",
]
