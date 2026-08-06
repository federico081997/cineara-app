<#
.SYNOPSIS
Starts the Cineara FastAPI development server.

.DESCRIPTION
Validates the Cineara backend structure, prepares the backend environment,
optionally starts PostgreSQL and Redis through Docker Compose, synchronises
Python dependencies with uv, and launches the FastAPI application with Uvicorn.

By default, the script performs the following operations:

1. Verifies the expected repository and backend files.
2. Creates backend\.env from backend\.env.example when necessary.
3. Starts the PostgreSQL and Redis Docker Compose services.
4. Waits for both containers to report a healthy status.
5. Synchronises all backend dependency groups with uv.
6. Starts Uvicorn with automatic source-code reloading enabled.

The script is intended primarily for local Cineara development.

.PARAMETER HostAddress
The network address on which Uvicorn listens.

The default value is 127.0.0.1, which makes the API accessible only from the
local machine.

Use 0.0.0.0 when the API must be reachable from another device on the same
network, such as a physical Android phone.

.PARAMETER Port
The TCP port on which the Cineara API listens.

The default value is 8000. Valid values range from 1 through 65535.

.PARAMETER SkipServices
Prevents the script from starting PostgreSQL and Redis through Docker Compose.

Use this option when the required services are already running or are hosted
outside the local Docker environment.

.PARAMETER SkipSync
Prevents the script from running:

    uv sync --all-groups

Use this option when the backend environment is already synchronised and the
dependencies have not changed.

.PARAMETER NoReload
Starts Uvicorn without automatic source-code reloading.

This is useful when debugging reload-related behaviour or when running the API
in a more production-like mode.

.PARAMETER Help
Displays the complete script documentation and exits without starting any
services or applications.

The shorter -h alias can also be used.

.EXAMPLE
PS> .\start-api.ps1

Starts PostgreSQL and Redis, synchronises dependencies, and launches the API
at http://127.0.0.1:8000 with automatic reloading enabled.

.EXAMPLE
PS> .\start-api.ps1 -HostAddress 0.0.0.0 -Port 8080

Starts the API on port 8080 and binds it to all network interfaces. This allows
another device on the local network to connect to the API.

.EXAMPLE
PS> .\start-api.ps1 -SkipServices

Starts the API without starting PostgreSQL or Redis. The services must already
be available.

.EXAMPLE
PS> .\start-api.ps1 -SkipServices -SkipSync -NoReload

Starts the API without managing Docker services, without synchronising
dependencies, and without enabling automatic reload.

.EXAMPLE
PS> .\start-api.ps1 -Help

Displays the complete script documentation.

.EXAMPLE
PS> Get-Help .\start-api.ps1 -Examples

Displays only the usage examples.

.INPUTS
None.

.OUTPUTS
None. The script writes progress messages to the console and runs Uvicorn as a
foreground process.

.NOTES
Required tools:

- PowerShell 7 or later is recommended.
- uv must be installed and available through PATH.
- Docker Desktop and Docker Compose v2 are required unless -SkipServices is used.

Expected repository structure:

    cineara\
    |-- backend\
    |   |-- .env.example
    |   |-- pyproject.toml
    |   `-- src\
    |       `-- cineara\
    |           `-- main.py
    |
    |-- docker-compose.yml
    `-- scripts\
        `-- <directory>\
            `-- start-api.ps1

The script assumes that it is located exactly two directories below the
repository root.
#>

[CmdletBinding()]
param(
    [Parameter(
            HelpMessage = "Network address on which the API should listen."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$HostAddress = "127.0.0.1",

    [Parameter(
            HelpMessage = "TCP port on which the API should listen."
    )]
    [ValidateRange(1, 65535)]
    [int]$Port = 8000,

    [Parameter(
            HelpMessage = "Do not start PostgreSQL and Redis with Docker Compose."
    )]
    [switch]$SkipServices,

    [Parameter(
            HelpMessage = "Do not synchronise backend dependencies with uv."
    )]
    [switch]$SkipSync,

    [Parameter(
            HelpMessage = "Start Uvicorn without automatic source-code reloading."
    )]
    [switch]$NoReload,

    [Parameter(
            HelpMessage = "Display the complete script documentation."
    )]
    [Alias("h")]
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Display help before performing validation or changing the local environment.
if ($Help) {
    Get-Help -Name $PSCommandPath -Full | Out-Host
    return
}


# ---------------------------------------------------------------------------
# Console output helpers
# ---------------------------------------------------------------------------

function Write-Log {
    <#
    .SYNOPSIS
    Writes a standard Cineara API log message.
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[cineara-api] $Message"
}


function Write-WarningMessage {
    <#
    .SYNOPSIS
    Writes a Cineara API warning message.
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Warning "[cineara-api] $Message"
}


function Stop-WithError {
    <#
    .SYNOPSIS
    Writes an error message and terminates the script with exit code 1.
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Error "[cineara-api] $Message" -ErrorAction Continue
    exit 1
}


function Test-CommandExists {
    <#
    .SYNOPSIS
    Tests whether an executable or PowerShell command is available.
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return $null -ne (
    Get-Command -Name $Name -ErrorAction SilentlyContinue
    )
}


function Wait-ForContainerHealth {
    <#
    .SYNOPSIS
    Waits for a Docker Compose service to become healthy.

    .DESCRIPTION
    Finds the container associated with a Docker Compose service and repeatedly
    inspects its state until it reports healthy, enters a failure state, or the
    timeout expires.
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Service,

        [Parameter(Mandatory)]
        [string]$ComposeFile,

        [Parameter(Mandatory)]
        [string]$ProjectDirectory,

        [ValidateRange(1, 3600)]
        [int]$TimeoutSeconds = 90
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    $composeBaseArguments = @(
        "compose",
        "--project-directory",
        $ProjectDirectory,
        "--file",
        $ComposeFile
    )

    Write-Log "Waiting for $Service to become healthy..."

    while ((Get-Date) -lt $deadline) {
        $composePsArguments = $composeBaseArguments + @(
            "ps",
            "--quiet",
            $Service
        )

        $containerOutput = & docker @composePsArguments 2>$null
        $composePsExitCode = $LASTEXITCODE

        if ($composePsExitCode -ne 0) {
            Stop-WithError (
            "Docker Compose could not inspect the $Service service."
            )
        }

        $containerId = [string](
        $containerOutput |
                Select-Object -First 1
        )

        if (-not [string]::IsNullOrWhiteSpace($containerId)) {
            $inspectArguments = @(
                "inspect",
                "--format",
                "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}",
                $containerId.Trim()
            )

            $inspectOutput = & docker @inspectArguments 2>$null
            $inspectExitCode = $LASTEXITCODE

            if ($inspectExitCode -eq 0) {
                $containerStatus = [string](
                $inspectOutput |
                        Select-Object -First 1
                )

                $containerStatus = (
                $containerStatus.Trim().ToLowerInvariant()
                )

                switch ($containerStatus) {
                    "healthy" {
                        Write-Log "$Service is healthy."
                        return
                    }

                    "unhealthy" {
                        Stop-WithError "$Service became unhealthy."
                    }

                    "exited" {
                        Stop-WithError (
                        "$Service exited before becoming healthy."
                        )
                    }

                    "dead" {
                        Stop-WithError (
                        "$Service entered the Docker dead state."
                        )
                    }

                    "removing" {
                        Stop-WithError (
                        "$Service is being removed by Docker."
                        )
                    }
                }
            }
        }

        Start-Sleep -Seconds 2
    }

    Stop-WithError (
    "Timed out after $TimeoutSeconds seconds while waiting for " +
            "$Service to become healthy. Check the container logs and confirm " +
            "that the service has a Docker health check."
    )
}


# ---------------------------------------------------------------------------
# Repository paths
# ---------------------------------------------------------------------------

$ScriptDirectory = $PSScriptRoot

$RepositoryRoot = [System.IO.Path]::GetFullPath(
        (Join-Path -Path $ScriptDirectory -ChildPath "..\..")
)

$BackendDirectory = Join-Path `
    -Path $RepositoryRoot `
    -ChildPath "backend"

$BackendEnvFile = Join-Path `
    -Path $BackendDirectory `
    -ChildPath ".env"

$BackendEnvExample = Join-Path `
    -Path $BackendDirectory `
    -ChildPath ".env.example"

$BackendPyproject = Join-Path `
    -Path $BackendDirectory `
    -ChildPath "pyproject.toml"

$BackendMain = Join-Path `
    -Path $BackendDirectory `
    -ChildPath "src\cineara\main.py"

$ComposeFile = Join-Path `
    -Path $RepositoryRoot `
    -ChildPath "docker-compose.yml"


# ---------------------------------------------------------------------------
# Repository validation
# ---------------------------------------------------------------------------

if (-not (
Test-Path -LiteralPath $BackendDirectory -PathType Container
)) {
    Stop-WithError "Backend directory not found: $BackendDirectory"
}

if (-not (
Test-Path -LiteralPath $BackendPyproject -PathType Leaf
)) {
    Stop-WithError "Backend pyproject.toml not found: $BackendPyproject"
}

if (-not (
Test-Path -LiteralPath $BackendMain -PathType Leaf
)) {
    Stop-WithError "FastAPI entry point not found: $BackendMain"
}


# ---------------------------------------------------------------------------
# Backend environment file
# ---------------------------------------------------------------------------

if (-not (
Test-Path -LiteralPath $BackendEnvFile -PathType Leaf
)) {
    if (-not (
    Test-Path -LiteralPath $BackendEnvExample -PathType Leaf
    )) {
        Stop-WithError (
        "Neither backend\.env nor backend\.env.example exists."
        )
    }

    Copy-Item `
        -LiteralPath $BackendEnvExample `
        -Destination $BackendEnvFile

    Write-Log "Created backend\.env from backend\.env.example."

    Write-WarningMessage (
    "Review backend\.env before using Cineara outside local development."
    )
}
else {
    Write-Log "Using environment file: $BackendEnvFile"
}


# ---------------------------------------------------------------------------
# Required commands
# ---------------------------------------------------------------------------

if (-not (Test-CommandExists -Name "uv")) {
    Stop-WithError (
    "uv is not installed or is not available through PATH."
    )
}

if (-not $SkipServices) {
    if (-not (Test-CommandExists -Name "docker")) {
        Stop-WithError (
        "Docker Desktop is required to start PostgreSQL and Redis."
        )
    }

    & docker compose version *> $null

    if ($LASTEXITCODE -ne 0) {
        Stop-WithError (
        "Docker Compose v2 is not installed or is unavailable."
        )
    }

    if (-not (
    Test-Path -LiteralPath $ComposeFile -PathType Leaf
    )) {
        Stop-WithError "Docker Compose file not found: $ComposeFile"
    }
}


# ---------------------------------------------------------------------------
# PostgreSQL and Redis
# ---------------------------------------------------------------------------

if (-not $SkipServices) {
    Write-Log "Starting PostgreSQL and Redis..."

    $composeUpArguments = @(
        "compose",
        "--project-directory",
        $RepositoryRoot,
        "--file",
        $ComposeFile,
        "up",
        "--detach",
        "postgres",
        "redis"
    )

    & docker @composeUpArguments

    if ($LASTEXITCODE -ne 0) {
        Stop-WithError (
        "Docker Compose failed to start PostgreSQL and Redis."
        )
    }

    Wait-ForContainerHealth `
        -Service "postgres" `
        -ComposeFile $ComposeFile `
        -ProjectDirectory $RepositoryRoot

    Wait-ForContainerHealth `
        -Service "redis" `
        -ComposeFile $ComposeFile `
        -ProjectDirectory $RepositoryRoot
}
else {
    Write-Log "Skipping PostgreSQL and Redis startup."
}


# ---------------------------------------------------------------------------
# Python dependency synchronisation
# ---------------------------------------------------------------------------

if (-not $SkipSync) {
    Write-Log "Synchronising backend dependencies..."

    Push-Location -LiteralPath $BackendDirectory

    try {
        & uv sync --all-groups

        if ($LASTEXITCODE -ne 0) {
            Stop-WithError (
            "uv dependency synchronisation failed."
            )
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Log "Skipping backend dependency synchronisation."
}


# ---------------------------------------------------------------------------
# Uvicorn configuration
# ---------------------------------------------------------------------------

$UvicornArguments = @(
    "run",
    "uvicorn",
    "cineara.main:app",
    "--host",
    $HostAddress,
    "--port",
    $Port.ToString()
)

if (-not $NoReload) {
    $SourceDirectory = Join-Path `
        -Path $BackendDirectory `
        -ChildPath "src"

    $UvicornArguments += @(
        "--reload",
        "--reload-dir",
        $SourceDirectory
    )
}

# 0.0.0.0 is a bind address. Use localhost when displaying browser URLs.
$BrowserHost = switch ($HostAddress) {
    "0.0.0.0" { "127.0.0.1" }
    "::" { "[::1]" }
    default { $HostAddress }
}


# ---------------------------------------------------------------------------
# Start the API
# ---------------------------------------------------------------------------

Write-Log "Starting Cineara API."
Write-Log "Listening:   ${HostAddress}:$Port"
Write-Log "API:         http://${BrowserHost}:$Port"
Write-Log "Swagger UI:  http://${BrowserHost}:$Port/docs"
Write-Log "Health:      http://${BrowserHost}:$Port/health"
Write-Log "Readiness:   http://${BrowserHost}:$Port/readiness"

if ($NoReload) {
    Write-Log "Auto-reload: disabled"
}
else {
    Write-Log "Auto-reload: enabled"
}

Write-Log "Press Ctrl+C to stop the API."

$SourceDirectory = Join-Path `
    -Path $BackendDirectory `
    -ChildPath "src"

$OriginalPythonPath = $env:PYTHONPATH
$PathSeparator = [System.IO.Path]::PathSeparator

Push-Location -LiteralPath $BackendDirectory

try {
    if ([string]::IsNullOrWhiteSpace($env:PYTHONPATH)) {
        $env:PYTHONPATH = $SourceDirectory
    }
    else {
        $env:PYTHONPATH = (
        "$SourceDirectory$PathSeparator$($env:PYTHONPATH)"
        )
    }

    & uv @UvicornArguments

    $apiExitCode = $LASTEXITCODE

    # Exit code 130 and Windows status 0xC000013A normally indicate Ctrl+C.
    $expectedExitCodes = @(
        0,
        130,
        -1073741510
    )

    if ($apiExitCode -notin $expectedExitCodes) {
        Stop-WithError (
        "The Cineara API exited with code $apiExitCode."
        )
    }
}
finally {
    if ($null -eq $OriginalPythonPath) {
        Remove-Item `
            -LiteralPath "Env:PYTHONPATH" `
            -ErrorAction SilentlyContinue
    }
    else {
        $env:PYTHONPATH = $OriginalPythonPath
    }

    Pop-Location
}

Write-Log "Cineara API stopped."
