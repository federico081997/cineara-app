<#
.SYNOPSIS
Streams Cineara Docker service logs.

.DESCRIPTION
Streams logs for the selected Cineara Docker Compose services.

.PARAMETER Services
Services whose logs should be shown.

Defaults to backend, postgres, and redis.

.PARAMETER Tail
Number of existing log lines shown before following new output.

Defaults to 200.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string[]]$Services = @(
    "backend",
    "postgres",
    "redis"
),

    [ValidateRange(0, 100000)]
    [int]$Tail = 200
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
    "logs",
    "--follow",
    "--tail",
    $Tail.ToString()
) + $Services

Write-CinearaLog (
"Streaming logs for: " +
        ($Services -join ", ")
)

& docker @composeArguments

$exitCode = $LASTEXITCODE

$expectedExitCodes = @(
    0,
    130,
    -1073741510
)

if ($exitCode -notin $expectedExitCodes)
{
    Stop-CinearaWithError (
    "Docker Compose logs exited with code $exitCode."
    )
}
