import 'dart:convert';
import 'dart:io';

import '../../core/models/word_timestamp.dart';

/// Invokes local faster_whisper (Python) for word-level timestamps.
/// Requires: pip install faster-whisper
abstract final class FasterWhisperBridge {
  static const String _modelSize = 'base';

  static Future<List<WordTimestamp>> transcribeWords(String audioPath) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      throw UnsupportedError(
        'faster_whisper bridge is configured for desktop targets.',
      );
    }

    const script = r'''
import json, sys
from faster_whisper import WhisperModel

audio_path = sys.argv[1]
model_size = sys.argv[2]
model = WhisperModel(model_size, device="cpu", compute_type="int8")
segments, _ = model.transcribe(audio_path, word_timestamps=True)

words = []
for segment in segments:
    if not segment.words:
        continue
    for word in segment.words:
        token = word.word.strip()
        if not token:
            continue
        words.append({
            "word": token,
            "startMs": int(round(word.start * 1000)),
            "endMs": int(round(word.end * 1000)),
            "confidence": float(word.probability),
        })

print(json.dumps(words))
''';

    final python = Platform.isWindows ? 'python' : 'python3';
    final result = await Process.run(
      python,
      ['-c', script, audioPath, _modelSize],
    );

    if (result.exitCode != 0) {
      throw StateError(
        'faster_whisper failed: ${result.stderr}'.trim(),
      );
    }

    final stdout = (result.stdout as String).trim();
    if (stdout.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(stdout) as List<dynamic>;
    return decoded
        .map(
          (entry) => WordTimestamp.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }
}
