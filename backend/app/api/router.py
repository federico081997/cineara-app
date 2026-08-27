"""Versioned HTTP router assembly for the Cineara API.

The API version prefix is owned exclusively by this module. Feature routers
define only their feature-local prefixes, for example Search owns ``/search``.

Keeping versioning here prevents duplicated prefixes and allows feature modules
to remain reusable within later API versions.
"""

from __future__ import annotations

from fastapi import APIRouter

from app.modules.search.api import router as search_router

# =============================================================================
# API router
# =============================================================================


api_router = APIRouter(
    prefix="/api/v1",
)

# =============================================================================
# Feature routers
# =============================================================================


api_router.include_router(
    search_router,
)
