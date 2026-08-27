<#
.SYNOPSIS
Starts Cineara for normal local backend development.

.DESCRIPTION
Starts PostgreSQL and Redis in Docker, waits for both to become healthy,
synchronises the Python environment, and runs FastAPI/Uvicorn directly on the
host with automatic reload.

This is the normal script to use while developing backend code.

.PARAMETER HostAddress
Uvicorn bind address. Defaults to 127.0.0.1.

Use 0.0.0.0 when a physical Android device must reach the API.

.PARAMETER Port
Uvicorn port. Defaults to 8000.

.PARAMETER SkipServices
Do not start PostgreSQL and Redis.

.PARAMETER SkipSync
Do not run uv sync --all-groups.

.PARAMETER NoReload
Disable Uvicorn automatic reload.

.PARAMETER StopServicesOnExit
Stop PostgreSQL and Redis after Uvicorn exits.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$HostAddress = "127.0.0.1",

    [ValidateRange(1, 65535)]
    [int]$Port = 8000,

    [switch]$SkipServices,

    [switch]$SkipSync,

    [switch]$NoReload,

    [switch]$StopServicesOnExit
)

. (
Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "_common.ps1"
)


# =============================================================================
# Validation
# =============================================================================


Assert-CinearaRepository
Initialize-CinearaEnvironment
Assert-CinearaUv

if (-not $SkipServices)
{
    Assert-CinearaDocker
}


# =============================================================================
# Infrastructure
# =============================================================================


if (-not $SkipServices)
{
    Write-CinearaLog (
    "Starting PostgreSQL and Redis..."
    )

    $composeArguments = (
    Get-CinearaComposeArguments
    ) + @(
        "up",
        "--detach",
        "postgres",
        "redis"
    )

    & docker @composeArguments

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Docker Compose failed to start PostgreSQL and Redis."
        )
    }

    Wait-CinearaServiceHealth `
        -Service "postgres"

    Wait-CinearaServiceHealth `
        -Service "redis"
}
else
{
    Write-CinearaLog (
    "Skipping PostgreSQL and Redis startup."
    )
}


# =============================================================================
# Python environment
# =============================================================================


if (-not $SkipSync)
{
    Sync-CinearaBackend
}
else
{
    Write-CinearaLog (
    "Skipping backend dependency synchronisation."
    )
}


# =============================================================================
# Uvicorn
# =============================================================================


$uvicornArguments = @(
    "run",
    "uvicorn",
    "app.main:app",
    "--host",
    $HostAddress,
    "--port",
    $Port.ToString()
)

if (-not $NoReload)
{
    $uvicornArguments += @(
        "--reload",
        "--reload-dir",
        $script:CinearaBackendAppDirectory
    )
}

$browserHost = switch ($HostAddress)
{
    "0.0.0.0" {
        "127.0.0.1"
    }

    "::" {
        "[::1]"
    }

    default {
        $HostAddress
    }
}

Write-CinearaLog "Starting Cineara API."
Write-CinearaLog "API:         http://${browserHost}:$Port"
Write-CinearaLog "Swagger UI:  http://${browserHost}:$Port/docs"
Write-CinearaLog "Health:      http://${browserHost}:$Port/health"
Write-CinearaLog "Readiness:   http://${browserHost}:$Port/ready"

if ($NoReload)
{
    Write-CinearaLog "Auto-reload: disabled"
}
else
{
    Write-CinearaLog "Auto-reload: enabled"
}

Write-CinearaLog "Press Ctrl+C to stop FastAPI."


# =============================================================================
# Run
# =============================================================================

Push-Location `
    -LiteralPath $script:CinearaBackendDirectory

try
{
    & uv @uvicornArguments

    $apiExitCode = $LASTEXITCODE

    $expectedExitCodes = @(
        0,
        130,
        -1073741510
    )

    if ($apiExitCode -notin $expectedExitCodes)
    {
        Stop-CinearaWithError (
        "The Cineara API exited with code $apiExitCode."
        )
    }
}
finally
{
    Pop-Location

    if (
    $StopServicesOnExit `
         -and -not $SkipServices
    )
    {
        Write-CinearaLog (
        "Stopping PostgreSQL and Redis..."
        )

        $stopArguments = (
        Get-CinearaComposeArguments
        ) + @(
            "stop",
            "postgres",
            "redis"
        )

        & docker @stopArguments

        if ($LASTEXITCODE -ne 0)
        {
            Write-CinearaWarning (
            "PostgreSQL and Redis could not be stopped cleanly."
            )
        }
    }
}

Write-CinearaLog "Cineara API stopped."
