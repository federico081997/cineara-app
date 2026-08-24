# syntax=docker/dockerfile:1.7

# =============================================================================
# uv
# =============================================================================
#
# Pin uv so backend container builds remain reproducible.
# =============================================================================

FROM ghcr.io/astral-sh/uv:0.11.32 AS uv


# =============================================================================
# Runtime
# =============================================================================

FROM python:3.12-slim AS runtime


# =============================================================================
# Python / uv environment
# =============================================================================

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=0 \
    PATH="/app/.venv/bin:${PATH}"


WORKDIR /app


# =============================================================================
# uv executable
# =============================================================================

COPY --from=uv /uv /uvx /bin/


# =============================================================================
# Python dependencies
# =============================================================================
#
# Copy dependency metadata before application source so Docker can reuse this
# layer whenever application code changes but dependencies do not.
#
# --frozen:
#     Require pyproject.toml and uv.lock to remain synchronized.
#
# --no-dev:
#     Do not install development/test dependencies in the runtime image.
#
# --no-install-project:
#     Install third-party dependencies only.
#
# Cineara's current backend is imported directly from:
#
#     /app/app
#
# so it does not need to be installed as a Python package.
# =============================================================================

COPY pyproject.toml uv.lock README.md ./

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync \
        --frozen \
        --no-dev \
        --no-install-project


# =============================================================================
# Cineara backend source
# =============================================================================
#
# Current structure:
#
# /app/
# ├── app/
# │   ├── main.py
# │   ├── api/
# │   ├── catalogue/
# │   ├── core/
# │   ├── integrations/
# │   └── modules/
# ├── pyproject.toml
# └── uv.lock
# =============================================================================

COPY app ./app


# =============================================================================
# Unprivileged runtime user
# =============================================================================

RUN groupadd \
        --system \
        cineara \
    && useradd \
        --system \
        --gid cineara \
        --home-dir /app \
        --no-create-home \
        cineara \
    && chown -R cineara:cineara /app


USER cineara


# =============================================================================
# API port
# =============================================================================

EXPOSE 8000


# =============================================================================
# Container health check
# =============================================================================
#
# This assumes Cineara still exposes:
#
#     GET /health
#
# Keep health checking lightweight: it should indicate whether FastAPI itself
# is alive rather than making a TMDB Search request.
# =============================================================================

HEALTHCHECK \
    --interval=30s \
    --timeout=3s \
    --start-period=10s \
    --retries=3 \
    CMD python -c \
        "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)" \
        || exit 1


# =============================================================================
# FastAPI
# =============================================================================
#
# Current ASGI entry point:
#
#     backend/app/main.py
#         ↓
#     app.main:app
# =============================================================================

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
