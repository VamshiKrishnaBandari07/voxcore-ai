# VoiceCode Windows launcher — handles paths, SDK, and Developer Mode check.
$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot
$SourceProject = Split-Path -Parent $ScriptRoot
$RunProject = "C:\voicecode"
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"
# Space-free pub cache (username has a space; avoid broken C:\pub-cache copies).
$PubCache = "C:\ProgramData\Pub\Cache"

function Test-DeveloperModeEnabled {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $key)) { return $false }
    $value = (Get-ItemProperty -Path $key -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    return $value -eq 1
}

function Sync-Project {
    Write-Host "Syncing project to $RunProject (avoids OneDrive symlink issues)..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $RunProject -Force | Out-Null
    # Exclude ephemeral/build caches — Flutter recreates plugin symlinks locally.
    robocopy $SourceProject $RunProject /MIR /XD build .dart_tool .idea ephemeral /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
}

function Ensure-FlutterPlugins {
    Write-Host "Resolving packages and registering native plugins..." -ForegroundColor Cyan
    $ephemeral = Join-Path $RunProject "windows\flutter\ephemeral"
    if (Test-Path $ephemeral) {
        Remove-Item -Recurse -Force $ephemeral
    }

    & $FlutterBat pub get
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $registrant = Join-Path $RunProject "windows\flutter\generated_plugin_registrant.cc"
    if (-not (Test-Path $registrant)) {
        Write-Host "Plugin registrant missing after pub get." -ForegroundColor Red
        exit 1
    }
    $content = Get-Content $registrant -Raw
    if ($content -notmatch "RecordWindowsPlugin") {
        Write-Host "record_windows plugin was not registered. Check Developer Mode and pub cache." -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path $FlutterBat)) {
    Write-Host "Flutter not found at $FlutterRoot" -ForegroundColor Red
    Write-Host "Run: .\scripts\setup.ps1" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-DeveloperModeEnabled)) {
    Write-Host ""
    Write-Host "Windows Developer Mode is OFF." -ForegroundColor Yellow
    Write-Host "Flutter needs it for plugin symlinks." -ForegroundColor Yellow
    Write-Host "Opening Settings -> turn ON Developer Mode, then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Start-Process "ms-settings:developers"
    exit 1
}

# Avoid spaces in pub-cache path (username has a space).
New-Item -ItemType Directory -Path $PubCache -Force | Out-Null
$env:FLUTTER_ROOT = $FlutterRoot
$env:PUB_CACHE = $PubCache
$env:PATH = "$(Join-Path $FlutterRoot 'bin');$env:PATH"

Sync-Project
Set-Location $RunProject
Ensure-FlutterPlugins

Write-Host "Starting VoiceCode on Windows..." -ForegroundColor Green
& $FlutterBat run -d windows
exit $LASTEXITCODE
