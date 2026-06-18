import '../../core/database/db_helper.dart';
import '../../core/models/session.dart';
import '../../core/models/session_metrics.dart';
import '../../core/models/transcript.dart';
import '../../core/models/word_timestamp.dart';
import '../../core/repositories/speech_repository.dart';

/// SQLite-backed implementation of [SpeechRepository].
class SqliteSpeechRepository implements SpeechRepository {
  SqliteSpeechRepository(this._dbHelper);

  final DbHelper _dbHelper;

  Future<dynamic> get _db => _dbHelper.initialize();

  static const _metricsColumns = <String>[
    'wpm',
    'fluency_ratio',
    'filler_density',
    'pacing_stability',
    'total_word_count',
    'filler_count',
    'total_file_duration_ms',
    'total_silence_ms',
    'speaking_duration_ms',
    'clarity',
    'pronunciation',
    'fluency',
    'articulation',
    'pace',
    'breath',
    'overall_score',
  ];

  @override
  Future<int> createSession(Session session) async {
    final db = await _db;
    return db.insert('sessions', session.toMap());
  }

  @override
  Future<void> updateSession(Session session) async {
    if (session.id == null) {
      throw ArgumentError('Session id is required for update.');
    }
    final db = await _db;
    await db.update(
      'sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  @override
  Future<List<Session>> getSessions({int limit = 50}) async {
    final db = await _db;
    final rows = await db.query(
      'sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return <Session>[
      for (final row in rows)
        Session.fromMap(Map<String, Object?>.from(row)),
    ];
  }

  @override
  Future<Session?> getSessionById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Session.fromMap(Map<String, Object?>.from(rows.first));
  }

  @override
  Future<void> saveMetrics(int sessionId, Map<String, dynamic> metrics) async {
    final db = await _db;
    final payload = <String, Object?>{
      'session_id': sessionId,
      for (final column in _metricsColumns) column: metrics[column] ?? 0,
    };

    final existing = await getMetricsForSession(sessionId);
    if (existing != null) {
      await db.update(
        'metrics',
        payload,
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    } else {
      await db.insert('metrics', payload);
    }

    final overall = metrics['overall_score'];
    if (overall != null) {
      await db.update(
        'sessions',
        {'overall_score': overall},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getMetricsForSession(int sessionId) async {
    final db = await _db;
    final rows = await db.query(
      'metrics',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return {for (final column in _metricsColumns) column: row[column]};
  }

  @override
  Future<List<ScoreHistoryPoint>> getScoreHistory({int limit = 20}) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT s.id AS session_id, s.started_at, m.overall_score
      FROM sessions s
      INNER JOIN metrics m ON m.session_id = s.id
      WHERE m.overall_score > 0
      ORDER BY s.started_at ASC
      LIMIT ?
    ''', [limit]);

    return rows.map((row) {
      return ScoreHistoryPoint(
        sessionId: row['session_id'] as int,
        score: (row['overall_score'] as num).toDouble(),
        recordedAt: DateTime.parse(row['started_at'] as String),
      );
    }).toList();
  }

  @override
  Future<double?> getLatestOverallScore() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT overall_score FROM metrics
      WHERE overall_score > 0
      ORDER BY id DESC LIMIT 1
    ''');
    if (rows.isEmpty) return null;
    return (rows.first['overall_score'] as num?)?.toDouble();
  }

  @override
  Future<int> getPracticeStreakDays() async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT DISTINCT date(started_at) AS day
      FROM sessions
      ORDER BY day DESC
    ''');

    if (rows.isEmpty) return 0;

    var streak = 0;
    var expected = DateTime.now();
    expected = DateTime(expected.year, expected.month, expected.day);

    for (final row in rows) {
      final day = DateTime.parse(row['day'] as String);
      final dayOnly = DateTime(day.year, day.month, day.day);

      if (dayOnly == expected) {
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else if (dayOnly == expected.subtract(const Duration(days: 1)) && streak == 0) {
        expected = dayOnly;
        streak++;
        expected = expected.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  @override
  Future<void> saveTranscript(Transcript transcript) async {
    final db = await _db;
    final existing = await getTranscriptForSession(transcript.sessionId);
    final payload = transcript.toMap();

    if (existing?.id != null) {
      await db.update(
        'transcripts',
        payload,
        where: 'id = ?',
        whereArgs: [existing!.id],
      );
    } else {
      await db.insert('transcripts', payload);
    }
  }

  @override
  Future<void> saveEnrichedTranscript({
    required int sessionId,
    required String rawText,
    required String enrichedText,
    List<WordTimestamp> wordTimestamps = const [],
  }) {
    return saveTranscript(
      Transcript(
        sessionId: sessionId,
        rawText: rawText,
        enrichedText: enrichedText,
        wordTimestamps: wordTimestamps,
      ),
    );
  }

  @override
  Future<Transcript?> getTranscriptForSession(int sessionId) async {
    final db = await _db;
    final rows = await db.query(
      'transcripts',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Transcript.fromMap(rows.first);
  }

  @override
  Future<void> deleteSession(int id) async {
    final db = await _db;
    await db.delete('metrics', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('transcripts', where: 'session_id = ?', whereArgs: [id]);
    await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}
