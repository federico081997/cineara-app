"""FastAPI routes for Cineara Search.

This module exposes the public HTTP surface of the Search feature.

Routes
------
- ``GET /search/landing``
- ``GET /search/overview``
- ``GET /search``

The route layer owns:

- HTTP query parsing;
- FastAPI validation;
- dependency injection;
- HTTP-level translation of caller input errors.

It does not own:

- TMDB calls;
- caching;
- result mapping;
- Search orchestration;
- user-library state.

Adult-content policy is intentionally not exposed as a client-controlled query
parameter. It is configured when ``SearchService`` is constructed.
"""

from __future__ import annotations

from typing import Annotated

from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Query,
    status,
)

from app.api.dependencies import get_search_service

from .schemas import (
    SearchCategory,
    SearchLanding,
    SearchOverview,
    SearchPage,
)
from .service import SearchService

# =============================================================================
# Router
# =============================================================================


router = APIRouter(
    prefix="/search",
    tags=[
        "Search",
    ],
)

# =============================================================================
# Shared query types
# =============================================================================


SearchQuery = Annotated[
    str,
    Query(
        min_length=1,
        max_length=200,
        description="Text to search for.",
    ),
]

SearchLanguage = Annotated[
    str | None,
    Query(
        min_length=2,
        max_length=35,
        description=(
            "Optional TMDB response language, for example en-US or ja-JP."
        ),
    ),
]

SearchRegion = Annotated[
    str | None,
    Query(
        min_length=2,
        max_length=2,
        description=(
            "Optional two-letter region code used by compatible "
            "TMDB Search categories."
        ),
    ),
]

SearchServiceDependency = Annotated[
    SearchService,
    Depends(
        get_search_service,
    ),
]


# =============================================================================
# Landing
# =============================================================================


@router.get(
    "/landing",
    response_model=SearchLanding,
    summary="Get Search landing content",
)
async def get_search_landing(
    service: SearchServiceDependency,
    language: SearchLanguage = None,
) -> SearchLanding:
    """Return Search content shown before a query is committed."""

    return await service.landing(
        language=language,
    )


# =============================================================================
# Overview
# =============================================================================


@router.get(
    "/overview",
    response_model=SearchOverview,
    summary="Search all supported categories",
)
async def get_search_overview(
    service: SearchServiceDependency,
    q: SearchQuery,
    language: SearchLanguage = None,
    region: SearchRegion = None,
) -> SearchOverview:
    """Return grouped results for Cineara's All Search category."""

    try:
        return await service.overview(
            query=q,
            language=language,
            region=region,
        )

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(
                exc,
            ),
        ) from exc


# =============================================================================
# Dedicated category Search
# =============================================================================


@router.get(
    "",
    response_model=SearchPage,
    summary="Search one category",
)
async def search(
    service: SearchServiceDependency,
    q: SearchQuery,
    category: Annotated[
        SearchCategory,
        Query(
            alias="type",
            description="Dedicated Search category.",
        ),
    ],
    page: Annotated[
        int,
        Query(
            ge=1,
            description="TMDB result page.",
        ),
    ] = 1,
    language: SearchLanguage = None,
    region: SearchRegion = None,
) -> SearchPage:
    """Return one paginated dedicated Search category."""

    try:
        return await service.search(
            query=q,
            category=category,
            page=page,
            language=language,
            region=region,
        )

    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(
                exc,
            ),
        ) from exc
