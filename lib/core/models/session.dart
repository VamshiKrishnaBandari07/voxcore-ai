/// A recorded speech session stored locally on device.
class Session {
  const Session({
    this.id,
    required this.startedAt,
    this.endedAt,
    this.durationMs,
    this.audioPath,
    this.overallScore,
    this.createdAt,
  });

  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationMs;
  final String? audioPath;
  final double? overallScore;
  final DateTime? createdAt;

  Session copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMs,
    String? audioPath,
    double? overallScore,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      audioPath: audioPath ?? this.audioPath,
      overallScore: overallScore ?? this.overallScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_ms': durationMs,
      'audio_path': audioPath,
      'overall_score': overallScore,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory Session.fromMap(Map<String, Object?> map) {
    return Session(
      id: map['id'] as int?,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      durationMs: map['duration_ms'] as int?,
      audioPath: map['audio_path'] as String?,
      overallScore: (map['overall_score'] as num?)?.toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
