"""Top-level API router for the Cineara backend.

This module composes Cineara's feature routers under the versioned public API
prefix.

Feature modules own only their feature-specific paths.

For example:

    modules/search.py

defines:

    /search
    /search/enrich

while this module adds:

    /api/v1

producing the final public endpoints:

    GET  /api/v1/search
    POST /api/v1/search/enrich

Future Search endpoints should remain inside the Search module.

For example:

    GET /api/v1/search/suggestions

would be implemented in:

    app/modules/search.py

rather than by creating another Search router or module.
"""

from __future__ import annotations

from fastapi import APIRouter

from app.modules.search import router as search_router

# =============================================================================
# Public API router
# =============================================================================


api_router = APIRouter(
    prefix="/api/v1",
)

# =============================================================================
# Search
# =============================================================================
#
# modules/search.py defines:
#
#     GET  /search
#     POST /search/enrich
#
# Combined with this router's /api/v1 prefix:
#
#     GET  /api/v1/search
#     POST /api/v1/search/enrich
# =============================================================================


api_router.include_router(
    search_router,
)

# =============================================================================
# Public exports
# =============================================================================


__all__ = [
    "api_router",
]
