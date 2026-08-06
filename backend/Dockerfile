# syntax=docker/dockerfile:1.7

# Pin uv so container builds remain predictable.
FROM ghcr.io/astral-sh/uv:0.11.32 AS uv

FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/app/.venv/bin:${PATH}"

WORKDIR /app

# Copy the uv executables into the Python runtime image.
COPY --from=uv /uv /uvx /bin/

# Install third-party dependencies in a cache-friendly layer.
COPY pyproject.toml README.md ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev --no-install-project

# Copy and install the Cineara package.
COPY src ./src
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev

# Run the API as an unprivileged user.
RUN groupadd --system cineara \
    && useradd --system --gid cineara --home-dir /app cineara \
    && chown -R cineara:cineara /app

USER cineara

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)" || exit 1

CMD ["uvicorn", "cineara.main:app", "--host", "0.0.0.0", "--port", "8000"]
