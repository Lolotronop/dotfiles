<#
.SYNOPSIS
    Symlink configuration files/folders from this repository into Windows.

.DESCRIPTION
    - Source paths are relative to this script.
    - Destination paths must be absolute, but "~" is expanded to $HOME.
    - If source is a file and destination is an existing directory, the file is
      linked into that directory with its original filename.
    - Existing symlinks are left untouched.
    - Existing real files/directories are renamed to *.bak (or *.bakN if needed).
    - Waits for a keypress before exiting.

.PARAMETER ScoopLocation
    Scoop installation root.
#>

param(
    [string]$ScoopLocation = "D:\soft\scoop"
)

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Resolve-DestinationPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if ($Path.StartsWith("~")) {
        return $Path -replace "^~", $HOME
    }

    return $Path
}

function Get-BackupPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $candidate = "$Path.bak"
    $i = 1

    while (Test-Path $candidate) {
        $candidate = "$Path.bak$i"
        $i++
    }

    return $candidate
}

function Link-Config {
    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    $sourcePath = Join-Path $ScriptRoot $Source
    $destinationPath = Resolve-DestinationPath $Destination

    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Source not found: $sourcePath"
        return
    }

    $sourceItem = Get-Item $sourcePath

    # If linking a file into an existing directory, keep original filename.
    if (-not $sourceItem.PSIsContainer -and (Test-Path $destinationPath)) {
        $destItem = Get-Item $destinationPath
        if ($destItem.PSIsContainer) {
            $destinationPath = Join-Path $destinationPath $sourceItem.Name
        }
    }

    if (Test-Path $destinationPath) {
        $existing = Get-Item $destinationPath -Force

        # Existing symlink/junction -> leave alone.
        if (($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Write-Host "[SKIP] Already linked: $destinationPath" -ForegroundColor Yellow
            return
        }

        $backup = Get-BackupPath $destinationPath

        Move-Item $destinationPath $backup

        Write-Host "[BACKUP] $destinationPath -> $backup" -ForegroundColor Cyan
    }

    $parent = Split-Path $destinationPath -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $type = if ($sourceItem.PSIsContainer) { "Junction" } else { "SymbolicLink" }

    New-Item `
        -ItemType $type `
        -Path $destinationPath `
        -Target $sourcePath | Out-Null

    Write-Host "[LINK] $destinationPath -> $sourcePath" -ForegroundColor Green
}

function Get-FirefoxDefaultProfilePath {
    $profilesIni = Join-Path $env:APPDATA 'Mozilla\Firefox\profiles.ini'
    if (-not (Test-Path $profilesIni)) { return $null }

    $sections = @{}
    $current = $null

    foreach ($line in Get-Content $profilesIni) {
        if ($line -match '^\[(.+)\]$') {
            $current = $matches[1]
            $sections[$current] = @{}
            continue
        }

        if ($current -and $line -match '^(.*?)=(.*)$') {
            $sections[$current][$matches[1]] = $matches[2]
        }
    }

    $chosenPath = $null

    # First try Install* -> Default=... (often points to the real default-release profile)
    $installSection = $sections.Keys | Where-Object { $_ -like 'Install*' } | Select-Object -First 1
    if ($installSection -and $sections[$installSection].Default) {
        $chosenPath = $sections[$installSection].Default
    }
    else {
        # Fallback to the profile marked Default=1
        $defaultProfile = $sections.Keys |
            Where-Object { $_ -like 'Profile*' -and $sections[$_].Default -eq '1' } |
            Select-Object -First 1

        if ($defaultProfile) {
            $chosenPath = $sections[$defaultProfile].Path
            if ($sections[$defaultProfile].IsRelative -eq '1') {
                $chosenPath = Join-Path (Split-Path $profilesIni) $chosenPath
            }
        }
    }

    if (-not $chosenPath) { return $null }

    if ($chosenPath -notmatch '^[A-Za-z]:\\|^\\\\') {
        $chosenPath = Join-Path (Split-Path $profilesIni) $chosenPath
    }

    if (Test-Path $chosenPath) {
        return (Resolve-Path $chosenPath).Path
    }

    return $null
}

$firefoxProfilePath = Get-FirefoxDefaultProfilePath

if ($firefoxProfilePath) {
    Write-Host "Firefox profile found: $firefoxProfilePath" -ForegroundColor Green
    Link-Config `
        -Source "firefox" `
        -Destination "$firefoxProfilePath\chrome"
}
else {
    Write-Host "Firefox profile not found." -ForegroundColor Yellow
}

$Links = @(
    @{
        Source      = "wezterm\wezterm.lua"
        Destination = "~\.config\wezterm\wezterm.lua"
    },
    @{
        Source      = "wezterm\plugins"
        Destination = "~\.config\wezterm\plugins"
    },


    @{
        Source      = "filepilot\FPilot-Config.json"
        Destination = "~\AppData\Roaming\Voidstar\FilePilot\FPilot-Config.json"
    },
    @{
        Source      = "config.nu"
        Destination = "~\AppData\Roaming\nushell\config.nu"
    },
    @{
        Source      = "alacritty"
        Destination = "~\AppData\Roaming\alacritty"
    },
    @{
        Source      = "lazygit\config.yml"
        Destination = "~\AppData\Local\lazygit\config.yml"
    },

    @{
        Source      = "eq_apo"
        Destination = "C:\Program Files\EqualizerAPO\config"
    },

    @{
        Source      = "altsnap"
        Destination = "$ScoopLocation\persist\altsnap"
    },

    @{
        Source      = "mpv\scripts"
        Destination = "$ScoopLocation\persist\mpv\portable_config\scripts"
    },
    @{
        Source      = "mpv\script-opts"
        Destination = "$ScoopLocation\persist\mpv\portable_config\script-opts"
    },
    @{
        Source      = "mpv\fonts"
        Destination = "$ScoopLocation\persist\mpv\portable_config\fonts"
    },
    @{
        Source      = "mpv\mpv.conf"
        Destination = "$ScoopLocation\persist\mpv\portable_config\mpv.conf"
    },

    @{
        Source      = "sublime-text\Packages"
        Destination = "$ScoopLocation\persist\sublime-text\Data\Packages"
    },
    @{
        Source      = "sublime-text\Installed Packages"
        Destination = "$ScoopLocation\persist\sublime-text\Data\Installed Packages"
    }
)

foreach ($link in $Links) {
    Link-Config `
        -Source $link.Source `
        -Destination $link.Destination
}

###############################################################################

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Scoop location: $ScoopLocation"
Write-Host ""
Read-Host "Press Enter to exit..."
