# Patches platform permissions after flutter create
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

$androidManifest = Join-Path $ProjectRoot "android\app\src\main\AndroidManifest.xml"
if (Test-Path $androidManifest) {
    $lines = Get-Content $androidManifest
    if ($lines -notmatch "RECORD_AUDIO") {
        $manifestIndex = ($lines | Select-String -Pattern "<manifest").LineNumber
        if ($manifestIndex) {
            $insertAt = $manifestIndex  # 1-based
            $newLines = @()
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $newLines += $lines[$i]
                if ($i -eq ($insertAt - 1)) {
                    $newLines += '    <uses-permission android:name="android.permission.RECORD_AUDIO" />'
                }
            }
            Set-Content $androidManifest $newLines
            Write-Host "Patched Android microphone permission."
        }
    }
}

$iosPlist = Join-Path $ProjectRoot "ios\Runner\Info.plist"
if (Test-Path $iosPlist) {
    $content = Get-Content $iosPlist -Raw
    if ($content -notmatch "NSMicrophoneUsageDescription") {
        $entry = "`t<key>NSMicrophoneUsageDescription</key>`n`t<string>VoiceCode needs microphone access to record and analyze your speech locally.</string>`n"
        $content = $content -replace "</dict>", "$entry</dict>"
        Set-Content $iosPlist $content -NoNewline
        Write-Host "Patched iOS microphone permission."
    }
}

Write-Host "Permission patch complete."
