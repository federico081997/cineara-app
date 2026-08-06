"""Shared pytest fixtures for the Cineara backend."""

from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient

from cineara.main import app


@pytest.fixture
def client() -> Iterator[TestClient]:
    """Provide an in-process HTTP client for API tests."""
    with TestClient(app) as test_client:
        yield test_client
