# VoiceCode Windows launcher — builds Release bundle and opens the app.
$ErrorActionPreference = "Stop"
& (Join-Path $PSScriptRoot "launch.ps1")
exit $LASTEXITCODE
