import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/processed_transcript.dart';
import '../../../core/models/session.dart';
import '../../../core/models/transcript.dart';
import '../../../services/providers/app_providers.dart';

enum ProcessingStage {
  idle,
  transcribing,
  enriching,
  calculating,
  completed,
  error,
}

class ProcessingStatus {
  const ProcessingStatus({required this.stage, this.errorMessage});

  final ProcessingStage stage;
  final String? errorMessage;

  bool get isOverlayVisible =>
      stage != ProcessingStage.idle && stage != ProcessingStage.completed;

  bool get isActive =>
      stage == ProcessingStage.transcribing ||
      stage == ProcessingStage.enriching ||
      stage == ProcessingStage.calculating;

  bool get needsProcessing =>
      stage == ProcessingStage.idle || stage == ProcessingStage.error;

  String get label => switch (stage) {
        ProcessingStage.idle => 'Ready',
        ProcessingStage.transcribing => 'Transcribing audio',
        ProcessingStage.enriching => 'Enriching transcript',
        ProcessingStage.calculating => 'Calculating metrics',
        ProcessingStage.completed => 'Analysis complete',
        ProcessingStage.error => 'Processing failed',
      };

  int get stepIndex => switch (stage) {
        ProcessingStage.transcribing => 1,
        ProcessingStage.enriching => 2,
        ProcessingStage.calculating => 3,
        _ => 0,
      };
}

class SessionDetailState {
  const SessionDetailState({
    this.session,
    this.transcript,
    this.processingStage = ProcessingStage.idle,
    this.errorMessage,
    this.isInitialized = false,
  });

  final Session? session;
  final Transcript? transcript;
  final ProcessingStage processingStage;
  final String? errorMessage;
  final bool isInitialized;

  ProcessingStatus get processingStatus => ProcessingStatus(
        stage: processingStage,
        errorMessage: errorMessage,
      );

  SessionDetailState copyWith({
    Session? session,
    Transcript? transcript,
    ProcessingStage? processingStage,
    String? errorMessage,
    bool? isInitialized,
    bool clearError = false,
  }) {
    return SessionDetailState(
      session: session ?? this.session,
      transcript: transcript ?? this.transcript,
      processingStage: processingStage ?? this.processingStage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class SessionDetailViewModel
    extends AutoDisposeFamilyNotifier<SessionDetailState, int> {
  int get _sessionId => arg;

  @override
  SessionDetailState build(int sessionId) {
    Future.microtask(_loadSession);
    return const SessionDetailState();
  }

  Future<void> _loadSession() async {
    final repository = ref.read(speechRepositoryProvider);
    final session = await repository.getSessionById(_sessionId);

    if (session == null) {
      state = state.copyWith(
        processingStage: ProcessingStage.error,
        errorMessage: 'Session not found.',
        isInitialized: true,
      );
      return;
    }

    final existingTranscript =
        await repository.getTranscriptForSession(_sessionId);
    final existingMetrics = await repository.getMetricsForSession(_sessionId);

    final hasTranscript = existingTranscript?.enrichedText?.isNotEmpty ?? false;
    final hasMetrics = existingMetrics != null;

    state = SessionDetailState(
      session: session,
      transcript: existingTranscript,
      processingStage: hasTranscript && hasMetrics
          ? ProcessingStage.completed
          : ProcessingStage.idle,
      isInitialized: true,
    );
  }

  Future<void> deleteSession() async {
    await ref.read(speechRepositoryProvider).deleteSession(_sessionId);
    ref.invalidate(homeDashboardProvider);
  }

  Future<void> runProcessingPipeline() async {
    final session = state.session;
    if (session?.audioPath == null || session!.audioPath!.isEmpty) {
      state = state.copyWith(
        processingStage: ProcessingStage.error,
        errorMessage: 'No audio file found for this session.',
      );
      return;
    }

    final repository = ref.read(speechRepositoryProvider);
    final processor = ref.read(transcriptProcessorProvider);
    final metricsEngine = ref.read(metricsEngineProvider);

    ref.invalidate(transcriptProvider(_sessionId));
    ref.invalidate(metricsProvider(_sessionId));

    final existingTranscript =
        state.transcript ?? await repository.getTranscriptForSession(_sessionId);
    final hasEnrichedTranscript =
        existingTranscript?.enrichedText?.isNotEmpty ?? false;

    try {
      ProcessedTranscript processed;

      if (hasEnrichedTranscript) {
        state = state.copyWith(
          processingStage: ProcessingStage.calculating,
          clearError: true,
        );
        processed = await processor.buildProcessedFromStored(existingTranscript!);
      } else {
        state = state.copyWith(
          processingStage: ProcessingStage.transcribing,
          clearError: true,
        );

        final asrResult = await processor.runTranscription(session.audioPath!);
        state = state.copyWith(processingStage: ProcessingStage.enriching);

        processed = await processor.runEnrichment(asrResult);

        await repository.saveEnrichedTranscript(
          sessionId: _sessionId,
          rawText: processed.rawText,
          enrichedText: processed.enrichedText,
          wordTimestamps: processed.asrResult.words,
        );
      }

      state = state.copyWith(processingStage: ProcessingStage.calculating);

      final metrics = metricsEngine.compute(
        processed: processed,
        totalFileDurationMs: session.durationMs,
      );

      await repository.saveMetrics(_sessionId, metrics.toMap());

      ref.invalidate(transcriptProvider(_sessionId));
      ref.invalidate(metricsProvider(_sessionId));
      ref.invalidate(homeDashboardProvider);

      final updatedSession = await repository.getSessionById(_sessionId);
      final savedTranscript =
          await repository.getTranscriptForSession(_sessionId);

      state = state.copyWith(
        session: updatedSession ?? session,
        transcript: savedTranscript ??
            Transcript(
              sessionId: _sessionId,
              rawText: processed.rawText,
              enrichedText: processed.enrichedText,
              wordTimestamps: processed.asrResult.words,
            ),
        processingStage: ProcessingStage.completed,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        processingStage: ProcessingStage.error,
        errorMessage: error.toString(),
      );
    }
  }
}

final sessionDetailViewModelProvider = NotifierProvider.autoDispose
    .family<SessionDetailViewModel, SessionDetailState, int>(
  SessionDetailViewModel.new,
);

final processingStatusProvider = Provider.autoDispose
    .family<ProcessingStatus, int>((ref, sessionId) {
  return ref.watch(sessionDetailViewModelProvider(sessionId)).processingStatus;
});

final recommendationsProvider = Provider.autoDispose
    .family<List<TrainingRecommendationDisplay>, int>((ref, sessionId) {
  final metricsAsync = ref.watch(metricsProvider(sessionId));
  return metricsAsync.maybeWhen(
    data: (metrics) {
      if (metrics == null) return const [];
      final engine = ref.read(recommendationEngineProvider);
      return engine
          .recommend(metrics)
          .map(
            (r) => TrainingRecommendationDisplay(
              title: r.title,
              description: r.description,
            ),
          )
          .toList();
    },
    orElse: () => const [],
  );
});

class TrainingRecommendationDisplay {
  const TrainingRecommendationDisplay({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
