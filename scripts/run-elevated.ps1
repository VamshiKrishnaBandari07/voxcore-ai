$ErrorActionPreference = "Stop"
$FlutterRoot = Join-Path $env:USERPROFILE "flutter"
$FlutterBat = Join-Path $FlutterRoot "bin\flutter.bat"
$RunProject = "C:\voicecode"
$env:FLUTTER_ROOT = $FlutterRoot
$env:PUB_CACHE = "C:\ProgramData\Pub\Cache"
$env:PATH = "$(Join-Path $FlutterRoot 'bin');${env:PATH}"
Set-Location $RunProject
& $FlutterBat run -d windows
