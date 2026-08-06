# Cineara backend

Phase 1 provides a small FastAPI service with liveness and readiness endpoints. It deliberately avoids catalogue models, ORM entities and background-job infrastructure until their dedicated phases.

## Requirements

- Python 3.12
- uv
- PostgreSQL and Redis, normally started through the root Docker Compose file

## Install

```bash
cd backend
cp .env.example .env
uv sync --all-groups
```

## Run locally

Start PostgreSQL and Redis from the repository root:

```bash
docker compose up -d postgres redis
```

Then start FastAPI:

```bash
cd backend
uv run uvicorn cineara.main:app --reload --host 0.0.0.0 --port 8000
```

Endpoints:

```text
GET /           service metadata
GET /health     process liveness; does not call dependencies
GET /readiness  PostgreSQL TCP check plus Redis PING
GET /docs       generated Swagger UI
```

## Quality checks

```bash
uv run ruff format --check .
uv run ruff check .
uv run mypy src
uv run pytest
```

## Worker and scheduler

`cineara.worker` and `cineara.scheduler` are executable placeholders. They exist to reserve stable process entry points, but no jobs are run in Phase 1.
