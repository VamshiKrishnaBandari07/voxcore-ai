# VoiceCode one-time setup for Windows
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"
$PubCache = "C:\ProgramData\Pub\Cache"

Write-Host "VoiceCode Setup" -ForegroundColor Cyan
Write-Host "Project: $ProjectRoot"

if (-not (Test-Path $FlutterBat)) {
    Write-Host "Flutter SDK not found at $FlutterRoot" -ForegroundColor Red
    Write-Host "Extract flutter_windows_*-stable.zip so this exists:" -ForegroundColor Yellow
    Write-Host "  $FlutterBat" -ForegroundColor Yellow
    Write-Host "Also need: $FlutterRoot\packages\flutter_tools" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path (Join-Path $FlutterRoot "packages\flutter_tools"))) {
    Write-Host "Flutter SDK is incomplete (missing packages\flutter_tools)." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $PubCache -Force | Out-Null
$env:FLUTTER_ROOT = $FlutterRoot
$env:PUB_CACHE = $PubCache
$env:PATH = "$(Join-Path $FlutterRoot 'bin');${env:PATH}"

Set-Location $ProjectRoot

Write-Host "Flutter version:"
& $FlutterBat --version

& $FlutterBat config --enable-windows-desktop

if (-not (Test-Path (Join-Path $ProjectRoot "windows\CMakeLists.txt"))) {
    Write-Host "Generating platform folders..."
    & $FlutterBat create . --org com.voicecode --project-name voicecode --platforms=windows,android,ios
}

Write-Host "Installing dependencies..."
& $FlutterBat pub get

& (Join-Path $PSScriptRoot "patch_permissions.ps1")

Write-Host ""
Write-Host "IMPORTANT: Enable Windows Developer Mode (required to run):" -ForegroundColor Yellow
Write-Host "  Settings -> Privacy & security -> For developers -> Developer Mode ON" -ForegroundColor Yellow
Write-Host ""
Write-Host "Optional ASR: pip install faster-whisper" -ForegroundColor Yellow
Write-Host ""
Write-Host "Setup complete. Run: .\scripts\run.ps1" -ForegroundColor Green
