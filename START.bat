@echo off
REM Quick relaunch — skips rebuild if Release bundle already exists.
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -Command ^
  "$b='C:\voicecode\build\windows\x64\runner\Release'; $e=Join-Path $b 'voicecode.exe';" ^
  "if (Test-Path $e) { Start-Process $e -WorkingDirectory $b } else { & '.\scripts\launch.ps1' }"
