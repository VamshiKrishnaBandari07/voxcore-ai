# VoiceCode

Offline-first speech practice app for Windows (Flutter + Riverpod + SQLite).

## Quick start (Windows)

1. Install Flutter at `%USERPROFILE%\flutter` (full SDK with `packages\flutter_tools`).
2. Enable **Developer Mode**: Settings → Privacy & security → For developers.
3. Install **Visual Studio 2022 Build Tools** with “Desktop development with C++”.
4. Double-click **`RUN.bat`** or run:

```powershell
cd "path\to\english practise speeking"
.\scripts\run.ps1
```

The launcher syncs the project to `C:\voicecode`, resolves plugins, builds, and runs the app. Keep the terminal open while using the app.

## Optional: speech-to-text

For full transcripts after recording:

```powershell
pip install faster-whisper
```

## Project layout

- `lib/` — app code (Clean Architecture)
- `scripts/run.ps1` — Windows launcher
- `scripts/setup.ps1` — one-time Flutter setup

## Author

Vamshi Krishna Bandari
