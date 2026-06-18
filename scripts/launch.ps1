# Build VoiceCode (Release) and launch with all required DLLs in one folder.
$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot
$SourceProject = Split-Path -Parent $ScriptRoot
$RunProject = "C:\voicecode"
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"
$PubCache = "C:\ProgramData\Pub\Cache"
$BundleDir = Join-Path $RunProject "build\windows\x64\runner\Release"
$ExePath = Join-Path $BundleDir "voicecode.exe"

$RequiredDlls = @(
    "flutter_windows.dll",
    "record_windows_plugin.dll",
    "just_audio_windows_plugin.dll",
    "sqlite3_flutter_libs_plugin.dll",
    "sqlite3.dll"
)

function Test-DeveloperModeEnabled {
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $key)) { return $false }
    $value = (Get-ItemProperty -Path $key -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
    return $value -eq 1
}

function Sync-Project {
    Write-Host "Syncing project to $RunProject..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $RunProject -Force | Out-Null
    robocopy $SourceProject $RunProject /MIR /XD build .dart_tool .idea ephemeral /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
}

function Ensure-FlutterPlugins {
    Write-Host "Registering plugins..." -ForegroundColor Cyan
    $ephemeral = Join-Path $RunProject "windows\flutter\ephemeral"
    if (Test-Path $ephemeral) {
        Remove-Item -Recurse -Force $ephemeral
    }
    & $FlutterBat pub get
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Test-BundleComplete {
    if (-not (Test-Path $ExePath)) { return $false }
    foreach ($dll in $RequiredDlls) {
        if (-not (Test-Path (Join-Path $BundleDir $dll))) { return $false }
    }
    if (-not (Test-Path (Join-Path $BundleDir "data\flutter_assets"))) { return $false }
    return $true
}

function Build-App {
    Write-Host "Building VoiceCode (Release). First run may take a few minutes..." -ForegroundColor Cyan
    & $FlutterBat build windows --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Start-VoiceCode {
    if (-not (Test-BundleComplete)) {
        Write-Host "ERROR: Build bundle is incomplete at:" -ForegroundColor Red
        Write-Host "  $BundleDir" -ForegroundColor Red
        Write-Host "Missing files. Re-run this script." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Launching VoiceCode from:" -ForegroundColor Green
    Write-Host "  $BundleDir" -ForegroundColor Green
    Write-Host ""

    Get-Process -Name voicecode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath $ExePath -WorkingDirectory $BundleDir
}

if (-not (Test-Path $FlutterBat)) {
    Write-Host "Flutter not found at $FlutterRoot" -ForegroundColor Red
    Write-Host "Run: .\scripts\setup.ps1" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-DeveloperModeEnabled)) {
    Write-Host "Turn ON Developer Mode in Windows Settings, then run again." -ForegroundColor Yellow
    Start-Process "ms-settings:developers"
    exit 1
}

New-Item -ItemType Directory -Path $PubCache -Force | Out-Null
$env:FLUTTER_ROOT = $FlutterRoot
$env:PUB_CACHE = $PubCache
$flutterBin = Join-Path $FlutterRoot "bin"
$env:PATH = $flutterBin + ';' + $env:PATH

Sync-Project
Set-Location $RunProject
Ensure-FlutterPlugins

if (-not (Test-BundleComplete)) {
    Build-App
}

Start-VoiceCode
