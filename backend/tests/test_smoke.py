"""Smoke tests for the Phase 1 FastAPI service."""

from fastapi.testclient import TestClient

from cineara.dependencies import DependencyStatus, get_dependency_status
from cineara.main import app


def test_root_returns_service_metadata(client: TestClient) -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json()["name"] == "Cineara API"
    assert response.json()["documentation"] == "/docs"


def test_health_is_independent_of_external_services(
    client: TestClient,
) -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["service"] == "cineara-api"


def test_readiness_reports_available_dependencies(client: TestClient) -> None:
    def ready_dependencies() -> DependencyStatus:
        return DependencyStatus(postgres=True, redis=True)

    app.dependency_overrides[get_dependency_status] = ready_dependencies
    try:
        response = client.get("/readiness")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json() == {
        "status": "ready",
        "dependencies": {"postgres": True, "redis": True},
    }


def test_readiness_returns_503_when_a_dependency_is_missing(
    client: TestClient,
) -> None:
    def unavailable_dependencies() -> DependencyStatus:
        return DependencyStatus(postgres=True, redis=False)

    app.dependency_overrides[get_dependency_status] = unavailable_dependencies
    try:
        response = client.get("/readiness")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 503
    assert response.json()["status"] == "not_ready"
