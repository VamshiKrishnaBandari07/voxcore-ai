/// Deterministic speech metrics computed by [MetricsEngine].
class SessionMetrics {
  const SessionMetrics({
    required this.wpm,
    required this.fluencyRatio,
    required this.fillerDensity,
    required this.pacingStability,
    required this.totalWordCount,
    required this.fillerCount,
    required this.totalFileDurationMs,
    required this.totalSilenceMs,
    required this.speakingDurationMs,
    this.clarity = 0,
    this.pronunciation = 0,
    this.fluency = 0,
    this.articulation = 0,
    this.pace = 0,
    this.breath = 0,
    this.overallScore = 0,
  });

  final double wpm;
  final double fluencyRatio;
  final double fillerDensity;
  final double pacingStability;
  final int totalWordCount;
  final int fillerCount;
  final int totalFileDurationMs;
  final int totalSilenceMs;
  final int speakingDurationMs;
  final double clarity;
  final double pronunciation;
  final double fluency;
  final double articulation;
  final double pace;
  final double breath;
  final double overallScore;

  factory SessionMetrics.neutral() => const SessionMetrics(
        wpm: 0,
        fluencyRatio: 0,
        fillerDensity: 0,
        pacingStability: 0,
        totalWordCount: 0,
        fillerCount: 0,
        totalFileDurationMs: 0,
        totalSilenceMs: 0,
        speakingDurationMs: 0,
      );

  Map<String, dynamic> toMap() {
    return {
      'wpm': wpm,
      'fluency_ratio': fluencyRatio,
      'filler_density': fillerDensity,
      'pacing_stability': pacingStability,
      'total_word_count': totalWordCount,
      'filler_count': fillerCount,
      'total_file_duration_ms': totalFileDurationMs,
      'total_silence_ms': totalSilenceMs,
      'speaking_duration_ms': speakingDurationMs,
      'clarity': clarity,
      'pronunciation': pronunciation,
      'fluency': fluency,
      'articulation': articulation,
      'pace': pace,
      'breath': breath,
      'overall_score': overallScore,
    };
  }

  factory SessionMetrics.fromMap(Map<String, dynamic> map) {
    return SessionMetrics(
      wpm: _asDouble(map['wpm']),
      fluencyRatio: _asDouble(map['fluency_ratio']),
      fillerDensity: _asDouble(map['filler_density']),
      pacingStability: _asDouble(map['pacing_stability']),
      totalWordCount: _asInt(map['total_word_count']),
      fillerCount: _asInt(map['filler_count']),
      totalFileDurationMs: _asInt(map['total_file_duration_ms']),
      totalSilenceMs: _asInt(map['total_silence_ms']),
      speakingDurationMs: _asInt(map['speaking_duration_ms']),
      clarity: _asDouble(map['clarity']),
      pronunciation: _asDouble(map['pronunciation']),
      fluency: _asDouble(map['fluency']),
      articulation: _asDouble(map['articulation']),
      pace: _asDouble(map['pace']),
      breath: _asDouble(map['breath']),
      overallScore: _asDouble(map['overall_score']),
    );
  }

  static double _asDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static int _asInt(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// A scored session point for progress charts.
class ScoreHistoryPoint {
  const ScoreHistoryPoint({
    required this.sessionId,
    required this.score,
    required this.recordedAt,
  });

  final int sessionId;
  final double score;
  final DateTime recordedAt;
}
