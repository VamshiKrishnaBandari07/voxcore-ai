import '../../core/models/asr_result.dart';
import '../../core/models/word_timestamp.dart';
import 'audio_silence_detector.dart';
import 'faster_whisper_bridge.dart';

/// Top-level isolate worker: ASR + silence detection. Must stay deterministic.
Future<AsrResult> transcribeInIsolate(String audioPath) async {
  final silences = await AudioSilenceDetector.detect(audioPath);

  List<WordTimestamp> words;
  try {
    words = await FasterWhisperBridge.transcribeWords(audioPath);
  } catch (_) {
    words = const [];
  }

  words.sort((a, b) => a.startMs.compareTo(b.startMs));

  final fullText = words.map((w) => w.word).join(' ').trim();

  return AsrResult(
    fullText: fullText,
    words: words,
    silences: silences,
  );
}
