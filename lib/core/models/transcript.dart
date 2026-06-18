import 'dart:convert';

import 'word_timestamp.dart';

/// Raw and enriched transcript data linked to a session.
class Transcript {
  const Transcript({
    this.id,
    required this.sessionId,
    this.rawText,
    this.enrichedText,
    this.wordTimestamps = const [],
    this.createdAt,
  });

  final int? id;
  final int sessionId;
  final String? rawText;
  final String? enrichedText;
  final List<WordTimestamp> wordTimestamps;
  final DateTime? createdAt;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'raw_text': rawText,
      'enriched_text': enrichedText,
      'word_timestamps_json': wordTimestamps.isEmpty
          ? null
          : jsonEncode(wordTimestamps.map((w) => w.toJson()).toList()),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory Transcript.fromMap(Map<String, Object?> map) {
    return Transcript(
      id: map['id'] as int?,
      sessionId: map['session_id'] as int,
      rawText: map['raw_text'] as String?,
      enrichedText: map['enriched_text'] as String?,
      wordTimestamps: _parseWordTimestamps(map['word_timestamps_json']),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  static List<WordTimestamp> _parseWordTimestamps(Object? raw) {
    if (raw == null || raw.toString().isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw as String) as List<dynamic>;
    return decoded
        .map(
          (entry) => WordTimestamp.fromJson(
            Map<String, dynamic>.from(entry as Map),
          ),
        )
        .toList();
  }
}
