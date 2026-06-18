import 'asr_result.dart';

/// Output of [TranscriptProcessor]: raw text, enriched markers, optional LLM hints.
class ProcessedTranscript {
  const ProcessedTranscript({
    required this.rawText,
    required this.enrichedText,
    required this.asrResult,
    this.stressAndBreathHints = const [],
  });

  final String rawText;
  final String enrichedText;
  final AsrResult asrResult;
  final List<String> stressAndBreathHints;
}
