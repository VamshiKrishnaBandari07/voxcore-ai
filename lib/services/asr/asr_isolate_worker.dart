import '../../core/models/asr_result.dart';
import '../../core/models/word_timestamp.dart';
import 'audio_silence_detector.dart';
import 'faster_whisper_bridge.dart';

/// Local ASR + silence detection. Runs on the main isolate for Windows compatibility.
Future<AsrResult> transcribeInIsolate(String audioPath) async {
  final silences = await AudioSilenceDetector.detect(audioPath);

  List<WordTimestamp> words;
  try {
    words = await FasterWhisperBridge.transcribeWords(audioPath);
  } catch (_) {
    words = const [];
  }

  if (words.isNotEmpty) {
    words = List<WordTimestamp>.from(words)
      ..sort((a, b) => a.startMs.compareTo(b.startMs));
  }

  final fullText = words.map((w) => w.word).join(' ').trim();

  return AsrResult(
    fullText: fullText,
    words: words,
    silences: silences,
  );
}
