<#
.SYNOPSIS
Runs Cineara backend quality checks.

.DESCRIPTION
Synchronises the backend development environment and runs Ruff linting, Ruff
format verification, mypy strict type checking, and pytest.

.PARAMETER SkipSync
Do not run uv sync --all-groups.

.PARAMETER SkipTests
Do not run pytest.
#>

[CmdletBinding()]
param(
    [switch]$SkipSync,

    [switch]$SkipTests
)

. (
Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "_common.ps1"
)

Assert-CinearaRepository
Assert-CinearaUv

if (-not $SkipSync)
{
    Sync-CinearaBackend
}

Push-Location `
    -LiteralPath $script:CinearaBackendDirectory

try
{
    Write-CinearaLog "Running Ruff lint checks..."

    & uv run ruff check .

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Ruff lint checks failed."
        )
    }

    Write-CinearaLog "Checking Ruff formatting..."

    & uv run ruff format --check .

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Ruff format check failed."
        )
    }

    Write-CinearaLog "Running mypy..."

    & uv run mypy

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "mypy checks failed."
        )
    }

    if (-not $SkipTests)
    {
        Write-CinearaLog "Running pytest..."

        & uv run pytest

        if ($LASTEXITCODE -ne 0)
        {
            Stop-CinearaWithError (
            "pytest failed."
            )
        }
    }
    else
    {
        Write-CinearaLog "Skipping pytest."
    }
}
finally
{
    Pop-Location
}

Write-CinearaLog "All requested backend checks passed."
