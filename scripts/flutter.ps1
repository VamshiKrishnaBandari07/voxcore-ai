# VoiceCode Flutter wrapper
param(
    [Parameter(Mandatory = $true, Position = 0, ValueFromRemainingArguments = $true)]
    [string[]]$Command
)

$ErrorActionPreference = "Stop"
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"

if (-not (Test-Path $FlutterBat)) {
    throw "Flutter not found at $FlutterRoot"
}

$env:FLUTTER_ROOT = $FlutterRoot
$env:PUB_CACHE = "C:\ProgramData\Pub\Cache"
New-Item -ItemType Directory -Path $env:PUB_CACHE -Force | Out-Null
$env:PATH = "$(Join-Path $FlutterRoot 'bin');$env:PATH"

& $FlutterBat @Command
exit $LASTEXITCODE
