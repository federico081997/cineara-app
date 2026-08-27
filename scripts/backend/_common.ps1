Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"


# =============================================================================
# Repository paths
# =============================================================================


$script:CinearaScriptDirectory = $PSScriptRoot

$script:CinearaRepositoryRoot = [System.IO.Path]::GetFullPath(
        (
        Join-Path `
            -Path $script:CinearaScriptDirectory `
            -ChildPath "..\.."
        )
)

$script:CinearaBackendDirectory = Join-Path `
    -Path $script:CinearaRepositoryRoot `
    -ChildPath "backend"

$script:CinearaBackendAppDirectory = Join-Path `
    -Path $script:CinearaBackendDirectory `
    -ChildPath "app"

$script:CinearaBackendMain = Join-Path `
    -Path $script:CinearaBackendAppDirectory `
    -ChildPath "main.py"

$script:CinearaBackendEnvFile = Join-Path `
    -Path $script:CinearaBackendDirectory `
    -ChildPath ".env"

$script:CinearaBackendEnvExample = Join-Path `
    -Path $script:CinearaBackendDirectory `
    -ChildPath ".env.example"

$script:CinearaBackendPyproject = Join-Path `
    -Path $script:CinearaBackendDirectory `
    -ChildPath "pyproject.toml"

$script:CinearaBackendUvLock = Join-Path `
    -Path $script:CinearaBackendDirectory `
    -ChildPath "uv.lock"

$script:CinearaComposeFile = Join-Path `
    -Path $script:CinearaRepositoryRoot `
    -ChildPath "docker-compose.yml"


# =============================================================================
# Console output
# =============================================================================


function Write-CinearaLog
{
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Host "[cineara-backend] $Message"
}


function Write-CinearaWarning
{
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    Write-Warning "[cineara-backend] $Message"
}


function Stop-CinearaWithError
{
    param(
        [Parameter(Mandatory)]
        [string]$Message
    )

    throw "[cineara-backend] $Message"
}


# =============================================================================
# Command validation
# =============================================================================


function Test-CinearaCommand
{
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    return $null -ne (
    Get-Command `
            -Name $Name `
            -ErrorAction SilentlyContinue
    )
}


function Assert-CinearaUv
{
    if (-not (
    Test-CinearaCommand `
            -Name "uv"
    ))
    {
        Stop-CinearaWithError (
        "uv is not installed or is not available through PATH."
        )
    }
}


function Assert-CinearaDocker
{
    if (-not (
    Test-CinearaCommand `
            -Name "docker"
    ))
    {
        Stop-CinearaWithError (
        "Docker Desktop is not installed or is not available through PATH."
        )
    }

    & docker info *> $null

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Docker is installed but the Docker daemon is not available. " +
                "Start Docker Desktop and try again."
        )
    }

    & docker compose version *> $null

    if ($LASTEXITCODE -ne 0)
    {
        Stop-CinearaWithError (
        "Docker Compose v2 is not available."
        )
    }
}


# =============================================================================
# Repository validation
# =============================================================================


function Assert-CinearaRepository
{
    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaBackendDirectory `
            -PathType Container
    ))
    {
        Stop-CinearaWithError (
        "Backend directory not found: " +
                $script:CinearaBackendDirectory
        )
    }

    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaBackendAppDirectory `
            -PathType Container
    ))
    {
        Stop-CinearaWithError (
        "Backend app package not found: " +
                $script:CinearaBackendAppDirectory
        )
    }

    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaBackendMain `
            -PathType Leaf
    ))
    {
        Stop-CinearaWithError (
        "FastAPI entry point not found: " +
                $script:CinearaBackendMain
        )
    }

    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaBackendPyproject `
            -PathType Leaf
    ))
    {
        Stop-CinearaWithError (
        "Backend pyproject.toml not found: " +
                $script:CinearaBackendPyproject
        )
    }

    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaComposeFile `
            -PathType Leaf
    ))
    {
        Stop-CinearaWithError (
        "Docker Compose file not found: " +
                $script:CinearaComposeFile
        )
    }
}


# =============================================================================
# Environment file
# =============================================================================


function Initialize-CinearaEnvironment
{
    if (
    Test-Path `
            -LiteralPath $script:CinearaBackendEnvFile `
            -PathType Leaf
    )
    {
        Write-CinearaLog (
        "Using environment file: " +
                $script:CinearaBackendEnvFile
        )

        return
    }

    if (-not (
    Test-Path `
            -LiteralPath $script:CinearaBackendEnvExample `
            -PathType Leaf
    ))
    {
        Stop-CinearaWithError (
        "Neither backend\.env nor backend\.env.example exists."
        )
    }

    Copy-Item `
        -LiteralPath $script:CinearaBackendEnvExample `
        -Destination $script:CinearaBackendEnvFile

    Write-CinearaLog (
    "Created backend\.env from backend\.env.example."
    )

    Write-CinearaWarning (
    "Review backend\.env and set required secrets, including " +
            "CINEARA_TMDB_READ_ACCESS_TOKEN."
    )
}


# =============================================================================
# Docker Compose arguments
# =============================================================================


function Get-CinearaComposeArguments
{
    return @(
        "compose",
        "--project-directory",
        $script:CinearaRepositoryRoot,
        "--env-file",
        $script:CinearaBackendEnvFile,
        "--file",
        $script:CinearaComposeFile
    )
}


# =============================================================================
# Docker health
# =============================================================================


function Wait-CinearaServiceHealth
{
    param(
        [Parameter(Mandatory)]
        [string]$Service,

        [ValidateRange(1, 3600)]
        [int]$TimeoutSeconds = 120,

        [switch]$AppProfile
    )

    $deadline = (Get-Date).AddSeconds(
            $TimeoutSeconds
    )

    $composeArguments = Get-CinearaComposeArguments

    if ($AppProfile)
    {
        $composeArguments += @(
            "--profile",
            "app"
        )
    }

    Write-CinearaLog (
    "Waiting for $Service to become healthy..."
    )

    while ((Get-Date) -lt $deadline)
    {
        $psArguments = $composeArguments + @(
            "ps",
            "--quiet",
            $Service
        )

        $containerOutput = & docker @psArguments 2> $null

        if ($LASTEXITCODE -ne 0)
        {
            Stop-CinearaWithError (
            "Docker Compose could not inspect service '$Service'."
            )
        }

        $containerId = [string](
        $containerOutput |
                Select-Object -First 1
        )

        if (-not [string]::IsNullOrWhiteSpace(
                $containerId
        ))
        {
            $inspectOutput = & docker inspect `
                --format `
                "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}" `
                $containerId.Trim() `
                2> $null

            if ($LASTEXITCODE -eq 0)
            {
                $status = [string](
                $inspectOutput |
                        Select-Object -First 1
                )

                $status = $status.Trim().ToLowerInvariant()

                switch ($status)
                {
                    "healthy" {
                        Write-CinearaLog (
                        "$Service is healthy."
                        )
                        return
                    }

                    "unhealthy" {
                        Stop-CinearaWithError (
                        "$Service became unhealthy."
                        )
                    }

                    "exited" {
                        Stop-CinearaWithError (
                        "$Service exited before becoming healthy."
                        )
                    }

                    "dead" {
                        Stop-CinearaWithError (
                        "$Service entered Docker's dead state."
                        )
                    }

                    "removing" {
                        Stop-CinearaWithError (
                        "$Service is being removed by Docker."
                        )
                    }
                }
            }
        }

        Start-Sleep -Seconds 2
    }

    Stop-CinearaWithError (
    "Timed out after $TimeoutSeconds seconds waiting for " +
            "'$Service' to become healthy. Inspect its Docker logs."
    )
}


# =============================================================================
# Dependency synchronization
# =============================================================================


function Sync-CinearaBackend
{
    Assert-CinearaUv

    Write-CinearaLog (
    "Synchronising backend dependencies..."
    )

    Push-Location `
        -LiteralPath $script:CinearaBackendDirectory

    try
    {
        & uv sync --all-groups

        if ($LASTEXITCODE -ne 0)
        {
            Stop-CinearaWithError (
            "uv dependency synchronisation failed."
            )
        }
    }
    finally
    {
        Pop-Location
    }
}
