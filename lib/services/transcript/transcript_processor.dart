import '../../core/models/asr_result.dart';
import '../../core/models/processed_transcript.dart';
import '../../core/models/silence_region.dart';
import '../../core/models/transcript.dart';
import '../../core/models/word_timestamp.dart';
import '../asr/asr_service.dart';
import 'transcript_enricher.dart';

/// Top-level enrichment entry (runs on main isolate — no Isolate.run on Windows).
ProcessedTranscript enrichInIsolate(AsrResult asrResult) {
  return TranscriptEnricher.enrich(asrResult);
}

/// Orchestrates local ASR and deterministic transcript enrichment.
class TranscriptProcessor {
  TranscriptProcessor(this._asrService);

  final AsrService _asrService;

  Future<AsrResult> runTranscription(String audioPath) {
    return _asrService.transcribe(audioPath);
  }

  Future<ProcessedTranscript> runEnrichment(AsrResult asrResult) async {
    final enriched = enrichInIsolate(asrResult);
    final hints = analyzeStressAndBreath(enriched);

    return ProcessedTranscript(
      rawText: enriched.rawText,
      enrichedText: enriched.enrichedText,
      asrResult: enriched.asrResult,
      stressAndBreathHints: hints,
    );
  }

  Future<ProcessedTranscript> process(String audioPath) async {
    final asrResult = await runTranscription(audioPath);
    return runEnrichment(asrResult);
  }

  Future<ProcessedTranscript> buildProcessedFromStored(
    Transcript transcript,
  ) async {
    final words = transcript.wordTimestamps;
    final silences = _inferSilencesFromWords(words);

    return ProcessedTranscript(
      rawText: transcript.rawText ?? '',
      enrichedText: transcript.enrichedText ?? '',
      asrResult: AsrResult(
        fullText: transcript.rawText ?? '',
        words: words,
        silences: silences,
      ),
    );
  }

  static List<SilenceRegion> _inferSilencesFromWords(
    List<WordTimestamp> words,
  ) {
    if (words.length < 2) return const [];

    final silences = <SilenceRegion>[];
    for (var i = 1; i < words.length; i++) {
      final gapMs = words[i].startMs - words[i - 1].endMs;
      if (gapMs >= 500) {
        silences.add(
          SilenceRegion(
            startMs: words[i - 1].endMs,
            endMs: words[i].startMs,
          ),
        );
      }
    }
    return silences;
  }

  List<String> analyzeStressAndBreath(ProcessedTranscript transcript) {
    return const [];
  }
}
