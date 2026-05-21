$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot

$Targets = @(
    @{
        Name = "nvim"
        Source = Join-Path $RepoRoot "nvim"
        Destination = Join-Path $env:LOCALAPPDATA "nvim"
    },
    @{
        Name = "wezterm"
        Source = Join-Path $RepoRoot "wezterm"
        Destination = Join-Path $env:USERPROFILE ".config\wezterm"
    },
    @{
        Name = "nushell"
        Source = Join-Path $RepoRoot "nushell"
        Destination = Join-Path $env:USERPROFILE ".config\nushell"
    }
)

foreach ($Target in $Targets) {
    $Name = $Target.Name
    $Source = $Target.Source
    $Destination = $Target.Destination

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warning "Skipping $Name because source does not exist: $Source"
        continue
    }

    $DestinationParent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $DestinationParent -Force | Out-Null

    if (Test-Path -LiteralPath $Destination) {
        Write-Host "Removing existing $Name config: $Destination"
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    Write-Host "Linking $Name`: $Destination -> $Source"
    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
}

Write-Host "Done."
