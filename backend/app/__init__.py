"""Cineara backend application package.

The ``app`` package contains Cineara's API, application modules, shared
infrastructure, catalogue logic, and external-service integrations.

Subpackages expose their own public interfaces. The package root intentionally
performs no application initialization, dependency construction, network
operations, or eager imports.

The FastAPI application entry point is defined in ``app.main``.
"""

from __future__ import annotations
