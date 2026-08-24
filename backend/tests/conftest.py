"""Shared pytest fixtures for the Cineara backend."""

from collections.abc import Iterator

import pytest
from cineara.main import app
from fastapi.testclient import TestClient


@pytest.fixture
def client() -> Iterator[TestClient]:
    """Provide an in-process HTTP client for API tests."""
    with TestClient(app) as test_client:
        yield test_client
