# syntax=docker/dockerfile:1.7

# =============================================================================
# Builder
# =============================================================================

FROM python:3.13-slim-trixie AS builder

# Keep the uv version pinned for reproducible builds.
COPY --from=ghcr.io/astral-sh/uv:0.12.6 /uv /uvx /bin/

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_DEV=1 \
    UV_PYTHON_DOWNLOADS=0

WORKDIR /app

# Install dependency layers first so application source changes do not
# invalidate the full dependency cache.
COPY pyproject.toml uv.lock ./

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync \
        --locked \
        --no-install-project \
        --no-editable

# Copy only files allowed by backend/.dockerignore.
COPY . .

# Install Cineara itself as a non-editable package into the virtual
# environment. Development dependency groups remain excluded by UV_NO_DEV.
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync \
        --locked \
        --no-editable


# =============================================================================
# Runtime
# =============================================================================

FROM python:3.13-slim-trixie AS runtime

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Run the API as an unprivileged user.
RUN groupadd \
        --gid 10001 \
        cineara \
    && useradd \
        --uid 10001 \
        --gid cineara \
        --create-home \
        --shell /usr/sbin/nologin \
        cineara

# The project is installed non-editably in the builder, so the runtime image
# only needs the completed virtual environment.
COPY --from=builder \
    --chown=cineara:cineara \
    /app/.venv \
    /app/.venv

USER cineara

EXPOSE 8000

HEALTHCHECK \
    --interval=30s \
    --timeout=3s \
    --start-period=10s \
    --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).read()"]

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--proxy-headers"]
