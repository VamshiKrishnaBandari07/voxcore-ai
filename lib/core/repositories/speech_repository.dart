import '../models/session.dart';
import '../models/session_metrics.dart';
import '../models/transcript.dart';
import '../models/word_timestamp.dart';

/// Contract for local speech data access. UI and ViewModels depend on this abstraction.
abstract class SpeechRepository {
  Future<int> createSession(Session session);

  Future<void> updateSession(Session session);

  Future<List<Session>> getSessions({int limit = 50});

  Future<Session?> getSessionById(int id);

  Future<void> saveMetrics(int sessionId, Map<String, dynamic> metrics);

  Future<Map<String, dynamic>?> getMetricsForSession(int sessionId);

  Future<List<ScoreHistoryPoint>> getScoreHistory({int limit = 20});

  Future<double?> getLatestOverallScore();

  Future<int> getPracticeStreakDays();

  Future<void> saveTranscript(Transcript transcript);

  Future<void> saveEnrichedTranscript({
    required int sessionId,
    required String rawText,
    required String enrichedText,
    List<WordTimestamp> wordTimestamps = const [],
  });

  Future<Transcript?> getTranscriptForSession(int sessionId);

  Future<void> deleteSession(int id);
}
