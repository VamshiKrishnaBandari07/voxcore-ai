# VoiceCode — offline-first speech practice app for Windows.

## Open the app (pick ONE)

### Easiest — Desktop shortcut
Double-click **VoiceCode** on your Desktop.

### Quick start
Double-click **`START.bat`** in the project folder.

### First time / after code changes
Double-click **`RUN.bat`** — builds and installs to `C:\VoiceCodeApp`.

### Direct open (always works)
Double-click:
```
C:\VoiceCodeApp\OPEN.bat
```

---

## Important

- **Do NOT** copy only `voicecode.exe` — all DLLs must stay together.
- **Do NOT** run the exe from OneDrive — use `C:\VoiceCodeApp` instead.
- The app is installed at **`C:\VoiceCodeApp`** with all required files:
  - `voicecode.exe`
  - `flutter_windows.dll`
  - `record_windows_plugin.dll`
  - `just_audio_windows_plugin.dll`
  - `sqlite3_flutter_libs_plugin.dll`
  - `sqlite3.dll`
  - `data\` folder

---

## Setup (one time)

1. Flutter at `%USERPROFILE%\flutter`
2. **Developer Mode ON** — Settings → Privacy & security → For developers
3. Visual Studio 2022 Build Tools with Desktop C++
4. Run **`RUN.bat`** once

Optional transcripts: `pip install faster-whisper`

## GitHub

https://github.com/VamshiKrishnaBandari07/voxcore-ai

## Author

Vamshi Krishna Bandari
