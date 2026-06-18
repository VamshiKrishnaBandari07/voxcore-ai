@echo off
title VoiceCode
cd /d "C:\VoiceCodeApp"
if not exist "C:\VoiceCodeApp\voicecode.exe" (
    echo VoiceCode not installed yet. Running setup...
    cd /d "%~dp0"
    powershell -ExecutionPolicy Bypass -File ".\scripts\launch.ps1"
    exit /b %errorlevel%
)
start "" /D "C:\VoiceCodeApp" "C:\VoiceCodeApp\voicecode.exe"
