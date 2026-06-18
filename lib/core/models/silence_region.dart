/// Detected silent region in the audio timeline.
class SilenceRegion {
  const SilenceRegion({
    required this.startMs,
    required this.endMs,
  });

  final int startMs;
  final int endMs;

  double get durationSec => (endMs - startMs) / 1000.0;

  Map<String, dynamic> toJson() => {
        'startMs': startMs,
        'endMs': endMs,
      };

  factory SilenceRegion.fromJson(Map<String, dynamic> json) {
    return SilenceRegion(
      startMs: json['startMs'] as int,
      endMs: json['endMs'] as int,
    );
  }
}
