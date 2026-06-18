@echo off
title VoiceCode Setup
cd /d "%~dp0"
echo.
echo  VoiceCode - Setup and Launch
echo  ============================
echo.
powershell -ExecutionPolicy Bypass -File ".\scripts\launch.ps1"
if errorlevel 1 (
    echo.
    echo  FAILED - read the error above.
    pause
    exit /b 1
)
echo.
echo  SUCCESS - VoiceCode is open.
echo  Next time use START.bat or Desktop shortcut "VoiceCode"
timeout /t 4 >nul
