/// A single word aligned to the audio timeline (milliseconds for isolate safety).
class WordTimestamp {
  const WordTimestamp({
    required this.word,
    required this.startMs,
    required this.endMs,
    this.confidence,
  });

  final String word;
  final int startMs;
  final int endMs;
  final double? confidence;

  double get startSec => startMs / 1000.0;

  double get endSec => endMs / 1000.0;

  Map<String, dynamic> toJson() => {
        'word': word,
        'startMs': startMs,
        'endMs': endMs,
        if (confidence != null) 'confidence': confidence,
      };

  factory WordTimestamp.fromJson(Map<String, dynamic> json) {
    return WordTimestamp(
      word: json['word'] as String,
      startMs: json['startMs'] as int,
      endMs: json['endMs'] as int,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  }
}
