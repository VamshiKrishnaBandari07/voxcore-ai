import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/db_helper.dart';
import '../../core/models/session.dart';
import '../../core/models/session_metrics.dart';
import '../../core/models/transcript.dart';
import '../../core/repositories/speech_repository.dart';
import '../analytics/metrics_engine.dart';
import '../analytics/recommendation_engine.dart';
import '../asr/asr_availability.dart';
import '../asr/asr_service.dart';
import '../asr/local_asr_service.dart';
import '../audio/recording_service.dart';
import '../audio/session_audio_player_service.dart';
import '../transcript/transcript_processor.dart';
import '../repositories/sqlite_speech_repository.dart';

final dbHelperProvider = Provider<DbHelper>((ref) {
  final helper = DbHelper();
  ref.onDispose(helper.close);
  return helper;
});

final speechRepositoryProvider = Provider<SpeechRepository>((ref) {
  return SqliteSpeechRepository(ref.watch(dbHelperProvider));
});

final recordingServiceProvider = Provider<RecordingService>((ref) {
  final service = RecordingService();
  ref.onDispose(service.dispose);
  return service;
});

final asrServiceProvider = Provider<AsrService>((ref) {
  return LocalAsrService();
});

final transcriptProcessorProvider = Provider<TranscriptProcessor>((ref) {
  return TranscriptProcessor(ref.watch(asrServiceProvider));
});

final metricsEngineProvider = Provider<MetricsEngine>((ref) {
  return MetricsEngine();
});

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

final asrAvailableProvider = FutureProvider<bool>((ref) {
  return AsrAvailability.isAvailable();
});

final metricsProvider = FutureProvider.autoDispose
    .family<SessionMetrics?, int>((ref, sessionId) async {
  final repository = ref.watch(speechRepositoryProvider);
  final map = await repository.getMetricsForSession(sessionId);
  if (map == null) return null;
  return SessionMetrics.fromMap(map);
});

final transcriptProvider = FutureProvider.autoDispose
    .family<Transcript?, int>((ref, sessionId) async {
  final repository = ref.watch(speechRepositoryProvider);
  return repository.getTranscriptForSession(sessionId);
});

final scoreHistoryProvider = FutureProvider<List<ScoreHistoryPoint>>((ref) async {
  final repository = ref.watch(speechRepositoryProvider);
  return repository.getScoreHistory(limit: 12);
});

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final repository = ref.watch(speechRepositoryProvider);
  final sessions = await repository.getSessions(limit: 20);
  final latestScore = await repository.getLatestOverallScore();
  final streak = await repository.getPracticeStreakDays();
  final history = await repository.getScoreHistory(limit: 12);
  final asrReady = await AsrAvailability.isAvailable();

  return HomeDashboardData(
    sessionCount: sessions.length,
    latestScore: latestScore,
    streakDays: streak,
    scoreHistory: history,
    asrAvailable: asrReady,
    recentSessions: sessions,
  );
});

final sessionAudioPlayerProvider = Provider.autoDispose
    .family<SessionAudioPlayerService, int>((ref, sessionId) {
  final service = SessionAudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});

/// Aggregated home dashboard data.
class HomeDashboardData {
  const HomeDashboardData({
    required this.sessionCount,
    required this.latestScore,
    required this.streakDays,
    required this.scoreHistory,
    required this.asrAvailable,
    required this.recentSessions,
  });

  final int sessionCount;
  final double? latestScore;
  final int streakDays;
  final List<ScoreHistoryPoint> scoreHistory;
  final bool asrAvailable;
  final List<Session> recentSessions;
}
