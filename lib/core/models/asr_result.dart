import 'silence_region.dart';
import 'word_timestamp.dart';

/// Local ASR output with word-level alignment and silence regions.
class AsrResult {
  const AsrResult({
    required this.fullText,
    required this.words,
    required this.silences,
  });

  final String fullText;
  final List<WordTimestamp> words;
  final List<SilenceRegion> silences;

  Map<String, dynamic> toJson() => {
        'fullText': fullText,
        'words': words.map((w) => w.toJson()).toList(),
        'silences': silences.map((s) => s.toJson()).toList(),
      };

  factory AsrResult.fromJson(Map<String, dynamic> json) {
    return AsrResult(
      fullText: json['fullText'] as String? ?? '',
      words: (json['words'] as List<dynamic>? ?? [])
          .map((e) => WordTimestamp.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      silences: (json['silences'] as List<dynamic>? ?? [])
          .map((e) => SilenceRegion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
