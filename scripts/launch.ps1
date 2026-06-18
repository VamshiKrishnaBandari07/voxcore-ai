# Build, publish to C:\VoiceCodeApp, and launch VoiceCode.
param([switch]$Rebuild)

$ErrorActionPreference = "Stop"

$ScriptRoot = $PSScriptRoot
$SourceProject = Split-Path -Parent $ScriptRoot
$RunProject = "C:\voicecode"
$AppDir = "C:\VoiceCodeApp"
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"
$PubCache = "C:\ProgramData\Pub\Cache"
$BundleDir = Join-Path $RunProject "build\windows\x64\runner\Release"
$ExePath = Join-Path $BundleDir "voicecode.exe"
$AppExe = Join-Path $AppDir "voicecode.exe"
$OpenBat = Join-Path $AppDir "OPEN.bat"

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
    Write-Host "Syncing source to $RunProject..." -ForegroundColor Cyan
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
    param([string]$Dir)
    $exe = Join-Path $Dir "voicecode.exe"
    if (-not (Test-Path $exe)) { return $false }
    foreach ($dll in $RequiredDlls) {
        if (-not (Test-Path (Join-Path $Dir $dll))) { return $false }
    }
    if (-not (Test-Path (Join-Path $Dir "data\flutter_assets"))) { return $false }
    return $true
}

function Build-App {
    Write-Host "Building VoiceCode (Release). First run takes 3-5 minutes..." -ForegroundColor Cyan
    & $FlutterBat build windows --release
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    if (-not (Test-BundleComplete $BundleDir)) {
        Write-Host "Build finished but DLL bundle is incomplete." -ForegroundColor Red
        exit 1
    }
}

function Publish-App {
    Write-Host "Publishing to $AppDir ..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $AppDir -Force | Out-Null
    robocopy $BundleDir $AppDir /MIR /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null

    @"
@echo off
title VoiceCode
cd /d "%~dp0"
start "" /D "%~dp0" "%~dp0voicecode.exe"
"@ | Set-Content -Path $OpenBat -Encoding ASCII

    $desktop = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktop "VoiceCode.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $OpenBat
    $shortcut.WorkingDirectory = $AppDir
    $shortcut.Description = "VoiceCode - Speech Practice"
    $shortcut.Save()

    Write-Host "Desktop shortcut created: $shortcutPath" -ForegroundColor Green
}

function Start-VoiceCode {
    if (-not (Test-BundleComplete $AppDir)) {
        Write-Host "ERROR: App folder incomplete at $AppDir" -ForegroundColor Red
        exit 1
    }
    Get-Process -Name voicecode -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "Opening VoiceCode..." -ForegroundColor Green
    Write-Host "  Folder: $AppDir" -ForegroundColor Green
    Write-Host ""
    Start-Process -FilePath $AppExe -WorkingDirectory $AppDir
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
$env:PATH = (Join-Path $FlutterRoot "bin") + ";" + $env:PATH

Sync-Project
Set-Location $RunProject
Ensure-FlutterPlugins

if (-not (Test-BundleComplete $BundleDir) -or $Rebuild) {
    Build-App
}

Publish-App
Start-VoiceCode
