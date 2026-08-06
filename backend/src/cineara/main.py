"""FastAPI application entry point for Cineara."""

from __future__ import annotations

from typing import Annotated, Literal

from fastapi import Depends, FastAPI, Response, status
from pydantic import BaseModel

from cineara import __version__
from cineara.dependencies import (
    DependencyStatus,
    Settings,
    get_dependency_status,
    get_settings,
)


class RootResponse(BaseModel):
    """Basic service metadata returned from the root endpoint."""

    name: str
    version: str
    documentation: str


class HealthResponse(BaseModel):
    """Liveness response that does not depend on external services."""

    status: Literal["ok"]
    service: str
    version: str
    environment: str


class ReadinessResponse(BaseModel):
    """Readiness response for load balancers and local diagnostics."""

    status: Literal["ready", "not_ready"]
    dependencies: DependencyStatus


def create_app() -> FastAPI:
    """Create and configure the Cineara FastAPI application."""
    settings = get_settings()
    application = FastAPI(
        title="Cineara API",
        summary="Backend API for the Cineara media application.",
        version=__version__,
        debug=settings.debug,
    )

    @application.get("/", response_model=RootResponse, tags=["system"])
    def root() -> RootResponse:
        return RootResponse(
            name="Cineara API",
            version=__version__,
            documentation="/docs",
        )

    @application.get("/health", response_model=HealthResponse, tags=["system"])
    def health(
        current_settings: Annotated[Settings, Depends(get_settings)],
    ) -> HealthResponse:
        return HealthResponse(
            status="ok",
            service="cineara-api",
            version=__version__,
            environment=current_settings.environment,
        )

    @application.get(
        "/readiness",
        response_model=ReadinessResponse,
        tags=["system"],
        responses={
            status.HTTP_503_SERVICE_UNAVAILABLE: {"model": ReadinessResponse}
        },
    )
    def readiness(
        response: Response,
        dependencies: Annotated[
            DependencyStatus, Depends(get_dependency_status)
        ],
    ) -> ReadinessResponse:
        if not dependencies.ready:
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE

        return ReadinessResponse(
            status="ready" if dependencies.ready else "not_ready",
            dependencies=dependencies,
        )

    return application


app = create_app()
