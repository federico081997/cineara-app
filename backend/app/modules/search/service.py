"""Application service for Cineara Search.

This module orchestrates TMDB Search/Trending operations, mapping, and optional
cache access.

The service is the application boundary between FastAPI routes and the TMDB
integration. It owns:

- dedicated category dispatch;
- grouped All-results overview orchestration;
- Search landing/trending orchestration;
- response mapping;
- versioned cache usage;
- configured Search policy such as adult-content inclusion and result limits.

It does not own:

- FastAPI request/response objects;
- raw HTTP transport;
- TMDB endpoint paths;
- presentation widgets;
- user-library state;
- persistence of catalogue entities.

Search deliberately performs no per-result Movie/TV Details calls.
"""

from __future__ import annotations

import asyncio
import logging
from typing import Protocol

from pydantic import BaseModel, ValidationError

from app.integrations.tmdb import TmdbClient
from app.integrations.tmdb.endpoints import TmdbTrendingTimeWindow

from ...core.cache import CacheError
from .cache_keys import (
    normalize_search_query,
    search_landing_cache_key,
    search_overview_cache_key,
    search_page_cache_key,
)
from .mapper import SearchMapper
from .schemas import (
    SearchCategory,
    SearchLanding,
    SearchOverview,
    SearchOverviewSection,
    SearchPage,
    SearchResult,
    TrendingSearchResult,
)

logger = logging.getLogger(
    __name__,
)


# =============================================================================
# Cache protocol
# =============================================================================


class SearchCache(Protocol):
    """Structural cache contract required by ``SearchService``.

    Cineara's concrete cache implementation may be Redis-backed or use another
    storage engine as long as it satisfies this asynchronous text/bytes
    contract.
    """

    async def get(
        self,
        key: str,
    ) -> str | bytes | None:
        """Return a serialized value or ``None``."""

        ...

    async def set(
        self,
        key: str,
        value: str,
        *,
        ttl_seconds: int,
    ) -> None:
        """Store a serialized value with a positive TTL."""

        ...


# =============================================================================
# Search service
# =============================================================================


class SearchService:
    """Production application service for Cineara Search."""

    __slots__ = (
        "_cache",
        "_include_adult",
        "_landing_cache_ttl_seconds",
        "_mapper",
        "_min_query_length",
        "_overview_cache_ttl_seconds",
        "_overview_section_limit",
        "_search_cache_ttl_seconds",
        "_tmdb",
        "_trending_limit",
        "_trending_time_window",
    )

    def __init__(
        self,
        *,
        tmdb: TmdbClient,
        cache: SearchCache | None = None,
        mapper: SearchMapper | None = None,
        include_adult: bool = False,
        min_query_length: int = 2,
        search_cache_ttl_seconds: int = 300,
        overview_cache_ttl_seconds: int = 180,
        landing_cache_ttl_seconds: int = 600,
        overview_section_limit: int = 5,
        trending_limit: int = 12,
        trending_time_window: TmdbTrendingTimeWindow = "week",
    ) -> None:
        """Create the Search application service."""

        if not isinstance(
            tmdb,
            TmdbClient,
        ):
            raise TypeError("tmdb must be a TmdbClient.")

        if not isinstance(
            include_adult,
            bool,
        ):
            raise TypeError("include_adult must be a bool.")

        self._tmdb = tmdb
        self._cache = cache
        self._mapper = mapper if mapper is not None else SearchMapper()
        self._include_adult = include_adult

        self._min_query_length = _positive_int(
            min_query_length,
            name="min_query_length",
        )
        self._search_cache_ttl_seconds = _positive_int(
            search_cache_ttl_seconds,
            name="search_cache_ttl_seconds",
        )
        self._overview_cache_ttl_seconds = _positive_int(
            overview_cache_ttl_seconds,
            name="overview_cache_ttl_seconds",
        )
        self._landing_cache_ttl_seconds = _positive_int(
            landing_cache_ttl_seconds,
            name="landing_cache_ttl_seconds",
        )
        self._overview_section_limit = _positive_int(
            overview_section_limit,
            name="overview_section_limit",
        )
        self._trending_limit = _positive_int(
            trending_limit,
            name="trending_limit",
        )

        if trending_time_window not in {
            "day",
            "week",
        }:
            raise ValueError("trending_time_window must be 'day' or 'week'.")

        self._trending_time_window = trending_time_window

    # =========================================================================
    # Dedicated Search
    # =========================================================================

    async def search(
        self,
        *,
        query: str,
        category: SearchCategory,
        page: int = 1,
        language: str | None = None,
        region: str | None = None,
    ) -> SearchPage:
        """Search one dedicated Cineara category."""

        normalized_query = self._normalize_query(
            query,
        )
        normalized_category = _normalize_category(
            category,
        )
        normalized_page = _positive_int(
            page,
            name="page",
        )

        cache_key = search_page_cache_key(
            query=normalized_query,
            category=normalized_category,
            page=normalized_page,
            language=language,
            include_adult=self._include_adult,
            region=region,
        )

        cached = await self._cache_read(
            cache_key,
            SearchPage,
        )

        if cached is not None:
            return cached

        result = await self._search_uncached(
            query=normalized_query,
            category=normalized_category,
            page=normalized_page,
            language=language,
            region=region,
        )

        await self._cache_write(
            cache_key,
            result,
            ttl_seconds=self._search_cache_ttl_seconds,
        )

        return result

    # =========================================================================
    # Overview
    # =========================================================================

    async def overview(
        self,
        *,
        query: str,
        language: str | None = None,
        region: str | None = None,
    ) -> SearchOverview:
        """Return grouped results for Cineara's All Search category."""

        normalized_query = self._normalize_query(
            query,
        )

        cache_key = search_overview_cache_key(
            query=normalized_query,
            language=language,
            include_adult=self._include_adult,
            region=region,
            section_limit=self._overview_section_limit,
        )

        cached = await self._cache_read(
            cache_key,
            SearchOverview,
        )

        if cached is not None:
            return cached

        (
            multi_page,
            collection_page,
            company_page,
            keyword_page,
        ) = await asyncio.gather(
            self._tmdb.search.multi(
                normalized_query,
                page=1,
                language=language,
                include_adult=self._include_adult,
            ),
            self._tmdb.search.collections(
                normalized_query,
                page=1,
                language=language,
                include_adult=self._include_adult,
                region=region,
            ),
            self._tmdb.search.companies(
                normalized_query,
                page=1,
            ),
            self._tmdb.search.keywords(
                normalized_query,
                page=1,
            ),
        )

        movie_results: list[SearchResult] = []
        tv_results: list[SearchResult] = []
        people_results: list[SearchResult] = []

        for raw_result in multi_page.results:
            mapped = self._mapper.multi(
                raw_result,
            )

            if mapped.result_type == "movie":
                if len(movie_results) < self._overview_section_limit:
                    movie_results.append(
                        mapped,
                    )

            elif mapped.result_type == "tv":
                if len(tv_results) < self._overview_section_limit:
                    tv_results.append(
                        mapped,
                    )

            else:
                if len(people_results) < self._overview_section_limit:
                    people_results.append(
                        mapped,
                    )

        collection_results = tuple(
            self._mapper.collection(
                item,
            )
            for item in collection_page.results[: self._overview_section_limit]
        )

        studio_results = tuple(
            self._mapper.studio(
                item,
            )
            for item in company_page.results[: self._overview_section_limit]
        )

        topic_results = tuple(
            self._mapper.topic(
                item,
            )
            for item in keyword_page.results[: self._overview_section_limit]
        )

        sections: list[SearchOverviewSection] = []

        _append_section_if_nonempty(
            sections,
            category=SearchCategory.MOVIES,
            results=tuple(movie_results),
        )
        _append_section_if_nonempty(
            sections,
            category=SearchCategory.TV,
            results=tuple(tv_results),
        )
        _append_section_if_nonempty(
            sections,
            category=SearchCategory.PEOPLE,
            results=tuple(people_results),
        )
        _append_section_if_nonempty(
            sections,
            category=SearchCategory.COLLECTIONS,
            results=collection_results,
            total_results=collection_page.total_results,
        )
        _append_section_if_nonempty(
            sections,
            category=SearchCategory.STUDIOS,
            results=studio_results,
            total_results=company_page.total_results,
        )
        _append_section_if_nonempty(
            sections,
            category=SearchCategory.TOPICS,
            results=topic_results,
            total_results=keyword_page.total_results,
        )

        result = SearchOverview(
            query=normalized_query,
            sections=tuple(
                sections,
            ),
        )

        await self._cache_write(
            cache_key,
            result,
            ttl_seconds=self._overview_cache_ttl_seconds,
        )

        return result

    # =========================================================================
    # Landing
    # =========================================================================

    async def landing(
        self,
        *,
        language: str | None = None,
    ) -> SearchLanding:
        """Return Search landing content."""

        cache_key = search_landing_cache_key(
            language=language,
            include_adult=self._include_adult,
            time_window=self._trending_time_window,
            limit=self._trending_limit,
        )

        cached = await self._cache_read(
            cache_key,
            SearchLanding,
        )

        if cached is not None:
            return cached

        page = await self._tmdb.trending.all(
            time_window=self._trending_time_window,
            language=language,
        )

        trending: list[TrendingSearchResult] = []

        for raw_result in page.results:
            if not self._include_adult and raw_result.adult:
                continue

            trending.append(
                self._mapper.multi(
                    raw_result,
                )
            )

            if len(trending) >= self._trending_limit:
                break

        result = SearchLanding(
            trending=tuple(
                trending,
            ),
        )

        await self._cache_write(
            cache_key,
            result,
            ttl_seconds=self._landing_cache_ttl_seconds,
        )

        return result

    # =========================================================================
    # Dedicated Search dispatch
    # =========================================================================

    async def _search_uncached(
        self,
        *,
        query: str,
        category: SearchCategory,
        page: int,
        language: str | None,
        region: str | None,
    ) -> SearchPage:
        """Execute one uncached dedicated Search operation."""

        if category is SearchCategory.MOVIES:
            movie_page = await self._tmdb.search.movies(
                query,
                page=page,
                language=language,
                include_adult=self._include_adult,
                region=region,
            )

            return SearchPage(
                query=query,
                category=category,
                page=movie_page.page,
                total_pages=movie_page.total_pages,
                total_results=movie_page.total_results,
                results=tuple(
                    self._mapper.movie(
                        item,
                    )
                    for item in movie_page.results
                ),
            )

        if category is SearchCategory.TV:
            tv_page = await self._tmdb.search.tv(
                query,
                page=page,
                language=language,
                include_adult=self._include_adult,
            )

            return SearchPage(
                query=query,
                category=category,
                page=tv_page.page,
                total_pages=tv_page.total_pages,
                total_results=tv_page.total_results,
                results=tuple(
                    self._mapper.tv(
                        item,
                    )
                    for item in tv_page.results
                ),
            )

        if category is SearchCategory.PEOPLE:
            people_page = await self._tmdb.search.people(
                query,
                page=page,
                language=language,
                include_adult=self._include_adult,
            )

            return SearchPage(
                query=query,
                category=category,
                page=people_page.page,
                total_pages=people_page.total_pages,
                total_results=people_page.total_results,
                results=tuple(
                    self._mapper.person(
                        item,
                    )
                    for item in people_page.results
                ),
            )

        if category is SearchCategory.COLLECTIONS:
            collection_page = await self._tmdb.search.collections(
                query,
                page=page,
                language=language,
                include_adult=self._include_adult,
                region=region,
            )

            return SearchPage(
                query=query,
                category=category,
                page=collection_page.page,
                total_pages=collection_page.total_pages,
                total_results=collection_page.total_results,
                results=tuple(
                    self._mapper.collection(
                        item,
                    )
                    for item in collection_page.results
                ),
            )

        if category is SearchCategory.STUDIOS:
            company_page = await self._tmdb.search.companies(
                query,
                page=page,
            )

            return SearchPage(
                query=query,
                category=category,
                page=company_page.page,
                total_pages=company_page.total_pages,
                total_results=company_page.total_results,
                results=tuple(
                    self._mapper.studio(
                        item,
                    )
                    for item in company_page.results
                ),
            )

        if category is SearchCategory.TOPICS:
            keyword_page = await self._tmdb.search.keywords(
                query,
                page=page,
            )

            return SearchPage(
                query=query,
                category=category,
                page=keyword_page.page,
                total_pages=keyword_page.total_pages,
                total_results=keyword_page.total_results,
                results=tuple(
                    self._mapper.topic(
                        item,
                    )
                    for item in keyword_page.results
                ),
            )

        raise ValueError(f"Unsupported Search category: {category!r}.")

    # =========================================================================
    # Query policy
    # =========================================================================

    def _normalize_query(
        self,
        value: str,
    ) -> str:
        normalized = normalize_search_query(
            value,
        )

        if len(normalized) < self._min_query_length:
            raise ValueError(
                "Search query must contain at least "
                f"{self._min_query_length} characters."
            )

        return normalized

    # =========================================================================
    # Cache helpers
    # =========================================================================

    async def _cache_read[ModelT: BaseModel](
        self,
        key: str,
        model: type[ModelT],
    ) -> ModelT | None:
        """Read and deserialize one cached model.

        Cache infrastructure failures and invalid cached payloads degrade to a
        normal cache miss so Search availability is not coupled to cache
        availability.
        """

        if self._cache is None:
            return None

        try:
            payload = await self._cache.get(
                key,
            )

        except CacheError:
            logger.warning(
                "Search cache read failed for key %s.",
                key,
                exc_info=True,
            )
            return None

        if payload is None:
            return None

        try:
            return model.model_validate_json(
                payload,
            )

        except ValidationError:
            logger.warning(
                "Ignoring invalid Search cache payload for key %s.",
                key,
                exc_info=True,
            )
            return None

    async def _cache_write(
        self,
        key: str,
        value: BaseModel,
        *,
        ttl_seconds: int,
    ) -> None:
        """Serialize and write one Search cache entry.

        Cache infrastructure failures are logged and ignored because cache
        availability must not determine Search availability.
        """

        if self._cache is None:
            return

        payload = value.model_dump_json()

        try:
            await self._cache.set(
                key,
                payload,
                ttl_seconds=ttl_seconds,
            )

        except CacheError:
            logger.warning(
                "Search cache write failed for key %s.",
                key,
                exc_info=True,
            )


# =============================================================================
# Overview helpers
# =============================================================================


def _append_section_if_nonempty(
    sections: list[SearchOverviewSection],
    *,
    category: SearchCategory,
    results: tuple[SearchResult, ...],
    total_results: int | None = None,
) -> None:
    """Append one overview section only when it contains results."""

    if not results:
        return

    sections.append(
        SearchOverviewSection(
            category=category,
            results=results,
            total_results=total_results,
        )
    )


# =============================================================================
# Validation
# =============================================================================


def _positive_int(
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


def _normalize_category(
    value: SearchCategory,
) -> SearchCategory:
    if not isinstance(
        value,
        SearchCategory,
    ):
        raise TypeError("category must be a SearchCategory.")

    return value
