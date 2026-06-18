import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/platform/app_paths.dart';
import 'package:record/record.dart';

/// Cross-platform audio capture. All file I/O stays on device.
class RecordingService {
  RecordingService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  /// Builds a persistent path under application support (desktop-first storage).
  Future<String> resolveRecordingPath() async {
    final supportPath = await resolveAppSupportDirectory();
    final recordingsDir = Directory(p.join(supportPath, 'recordings'));

    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    final fileName = 'session_${DateTime.now().millisecondsSinceEpoch}.wav';
    return p.join(recordingsDir.path, fileName);
  }

  /// Whisper-compatible capture: 16 kHz mono WAV.
  static const RecordConfig _recordConfig = RecordConfig(
    encoder: AudioEncoder.wav,
    sampleRate: 16000,
    numChannels: 1,
    bitRate: 128000,
  );

  /// Starts capturing audio to [path]. Caller must resolve the path first.
  Future<void> startRecording(String path) async {
    if (await _recorder.isRecording()) {
      throw StateError('Recording is already in progress.');
    }

    if (!await _recorder.hasPermission()) {
      throw StateError(
        'Microphone permission was denied. Enable mic access in Windows Settings.',
      );
    }

    await _recorder.start(_recordConfig, path: path);
  }

  /// Stops capture and returns the saved file path, if available.
  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) {
      return null;
    }

    return _recorder.stop();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
