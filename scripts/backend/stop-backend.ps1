<#
.SYNOPSIS
Stops the Cineara Docker backend infrastructure.

.DESCRIPTION
Stops and removes Cineara Docker Compose containers and networks while
preserving PostgreSQL and Redis data volumes by default.

.PARAMETER RemoveVolumes
Also delete the PostgreSQL and Redis named volumes.

This permanently removes local database and cache data.
#>

[CmdletBinding()]
param(
    [switch]$RemoveVolumes
)

. (
Join-Path `
        -Path $PSScriptRoot `
        -ChildPath "_common.ps1"
)

Assert-CinearaRepository
Initialize-CinearaEnvironment
Assert-CinearaDocker

$composeArguments = (
Get-CinearaComposeArguments
) + @(
    "--profile",
    "app",
    "down",
    "--remove-orphans"
)

if ($RemoveVolumes)
{
    Write-CinearaWarning (
    "Removing PostgreSQL and Redis data volumes."
    )

    $composeArguments += "--volumes"
}

Write-CinearaLog (
"Stopping Cineara Docker services..."
)

& docker @composeArguments

if ($LASTEXITCODE -ne 0)
{
    Stop-CinearaWithError (
    "Docker Compose failed to stop the Cineara backend."
    )
}

Write-CinearaLog "Cineara Docker services stopped."

if ($RemoveVolumes)
{
    Write-CinearaLog (
    "Local PostgreSQL and Redis data volumes were removed."
    )
}
else
{
    Write-CinearaLog (
    "PostgreSQL and Redis data volumes were preserved."
    )
}
