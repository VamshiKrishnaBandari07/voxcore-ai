/// Deterministic speech metrics for a session (computed locally, never by LLM).
class SpeechMetric {
  const SpeechMetric({
    this.id,
    required this.sessionId,
    this.clarity,
    this.pronunciation,
    this.fluency,
    this.articulation,
    this.pace,
    this.breath,
    this.wpm,
    this.createdAt,
  });

  final int? id;
  final int sessionId;
  final double? clarity;
  final double? pronunciation;
  final double? fluency;
  final double? articulation;
  final double? pace;
  final double? breath;
  final double? wpm;
  final DateTime? createdAt;

  /// Weighted overall score per VoiceCode scoring formula.
  double? get overallScore {
    final values = [clarity, pronunciation, fluency, articulation, pace, breath];
    if (values.any((v) => v == null)) return null;

    return (clarity! * 0.25) +
        (pronunciation! * 0.20) +
        (fluency! * 0.20) +
        (articulation! * 0.15) +
        (pace! * 0.10) +
        (breath! * 0.10);
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'clarity': clarity,
      'pronunciation': pronunciation,
      'fluency': fluency,
      'articulation': articulation,
      'pace': pace,
      'breath': breath,
      'wpm': wpm,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory SpeechMetric.fromMap(Map<String, Object?> map) {
    return SpeechMetric(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      clarity: (map['clarity'] as num?)?.toDouble(),
      pronunciation: (map['pronunciation'] as num?)?.toDouble(),
      fluency: (map['fluency'] as num?)?.toDouble(),
      articulation: (map['articulation'] as num?)?.toDouble(),
      pace: (map['pace'] as num?)?.toDouble(),
      breath: (map['breath'] as num?)?.toDouble(),
      wpm: (map['wpm'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
