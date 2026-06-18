# VoiceCode

Offline-first speech practice app for Windows (Flutter + Riverpod + SQLite).

## Quick start (Windows)

1. Install Flutter at `%USERPROFILE%\flutter` (full SDK with `packages\flutter_tools`).
2. Enable **Developer Mode**: Settings → Privacy & security → For developers.
3. Install **Visual Studio 2022 Build Tools** with “Desktop development with C++”.
4. Double-click **`RUN.bat`** (first time — builds) or **`START.bat`** (quick relaunch):

```powershell
cd "path\to\english practise speeking"
.\scripts\launch.ps1
```

**Important:** Do not run `voicecode.exe` from OneDrive or copy the `.exe` alone. All DLLs must stay in the same folder:

```
C:\voicecode\build\windows\x64\runner\Release\
```

The launcher syncs the project to `C:\voicecode`, builds Release, and opens the app from that folder.

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
