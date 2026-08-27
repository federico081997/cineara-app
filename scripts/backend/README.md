# Cineara backend runtime files

## Normal development

From `scripts/backend`:

```powershell
.\start-api.ps1
```

This runs PostgreSQL and Redis in Docker and FastAPI on the host with reload.

For a physical Android device:

```powershell
.\start-api.ps1 -HostAddress 0.0.0.0
```

## Production-like container test

```powershell
.\start-stack.ps1
```

This builds `backend/Dockerfile` and runs FastAPI, PostgreSQL, and Redis in
Docker.

## Quality checks

```powershell
.\check-backend.ps1
```

## Logs

```powershell
.\logs-backend.ps1
```

## Stop Docker services

```powershell
.\stop-backend.ps1
```

To delete local PostgreSQL and Redis data as well:

```powershell
.\stop-backend.ps1 -RemoveVolumes
```

## Important

The scripts pass `backend/.env` to Docker Compose as its interpolation
environment. Do not commit real secrets.

The Compose file is appropriate for development, CI/container validation,
staging, and a simple single-host deployment. For a larger production
deployment, keep the same backend image but normally replace the bundled
PostgreSQL/Redis services with managed infrastructure and inject secrets using
the deployment platform's secret manager.
