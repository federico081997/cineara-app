<#
.SYNOPSIS
Starts the complete Cineara backend stack in Docker.

.DESCRIPTION
Builds the production Dockerfile and starts FastAPI, PostgreSQL, and Redis
through Docker Compose. This is useful for production-like local testing,
staging on a single Docker host, and validating the container image.

.PARAMETER HostAddress
Host address on which the containerized API is published.

Defaults to 127.0.0.1.

.PARAMETER Port
Host port mapped to container port 8000.

Defaults to 8000.

.PARAMETER NoBuild
Do not rebuild the backend image before startup.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$HostAddress = "127.0.0.1",

    [ValidateRange(1, 65535)]
    [int]$Port = 8000,

    [switch]$NoBuild
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
Assert-CinearaDocker


# =============================================================================
# Compose port overrides
# =============================================================================


$originalBindAddress = $env:CINEARA_API_BIND_ADDRESS
$originalPublishedPort = $env:CINEARA_API_PUBLISHED_PORT

try
{
    $env:CINEARA_API_BIND_ADDRESS = $HostAddress
    $env:CINEARA_API_PUBLISHED_PORT = $Port.ToString()

    $composeArguments = (
    Get-CinearaComposeArguments
    ) + @(
        "--profile",
        "app",
        "up",
        "--detach"
    )

    if (-not $NoBuild)
    {
        $composeArguments += "--build"
    }

    Write-CinearaLog (
    "Starting containerized Cineara backend stack..."
    )

    & docker @composeArguments

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Docker Compose failed to start the Cineara stack."
        )
    }

    Wait-CinearaServiceHealth `
        -Service "postgres" `
        -AppProfile

    Wait-CinearaServiceHealth `
        -Service "redis" `
        -AppProfile

    Wait-CinearaServiceHealth `
        -Service "backend" `
        -TimeoutSeconds 180 `
        -AppProfile
}
finally
{
    if ($null -eq $originalBindAddress)
    {
        Remove-Item `
            -LiteralPath "Env:CINEARA_API_BIND_ADDRESS" `
            -ErrorAction SilentlyContinue
    }
    else
    {
        $env:CINEARA_API_BIND_ADDRESS = $originalBindAddress
    }

    if ($null -eq $originalPublishedPort)
    {
        Remove-Item `
            -LiteralPath "Env:CINEARA_API_PUBLISHED_PORT" `
            -ErrorAction SilentlyContinue
    }
    else
    {
        $env:CINEARA_API_PUBLISHED_PORT = $originalPublishedPort
    }
}


# =============================================================================
# Output
# =============================================================================


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

Write-CinearaLog "Containerized Cineara stack is healthy."
Write-CinearaLog "API:         http://${browserHost}:$Port"
Write-CinearaLog "Swagger UI:  http://${browserHost}:$Port/docs"
Write-CinearaLog "Health:      http://${browserHost}:$Port/health"
Write-CinearaLog "Readiness:   http://${browserHost}:$Port/ready"
Write-CinearaLog (
"Use .\stop-backend.ps1 when you are finished."
)
