@echo off
title VoiceCode
cd /d "%~dp0"
echo.
echo  VoiceCode - Building and launching...
echo  Do NOT run voicecode.exe from OneDrive. Use this file instead.
echo.
powershell -ExecutionPolicy Bypass -File ".\scripts\launch.ps1"
if errorlevel 1 (
    echo.
    echo  Launch failed. Read the error above.
    pause
    exit /b 1
)
echo.
echo  VoiceCode is running. You can close this window.
timeout /t 3 >nul
