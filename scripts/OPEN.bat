@echo off
REM Standalone launcher - copy this folder anywhere, always works.
cd /d "%~dp0"
if not exist "%~dp0voicecode.exe" (
    echo voicecode.exe not found in this folder.
    echo Run RUN.bat from the project folder first to install.
    pause
    exit /b 1
)
start "" /D "%~dp0" "%~dp0voicecode.exe"
