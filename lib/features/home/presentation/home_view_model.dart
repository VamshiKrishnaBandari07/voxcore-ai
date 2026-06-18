import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/session.dart';
import '../../../services/providers/app_providers.dart';

class HomeState {
  const HomeState({
    this.isRecording = false,
    this.currentPath,
    this.sessions = const [],
    this.lastCreatedSessionId,
    this.recordingElapsedSec = 0,
    this.errorMessage,
  });

  final bool isRecording;
  final String? currentPath;
  final List<Session> sessions;
  final int? lastCreatedSessionId;
  final int recordingElapsedSec;
  final String? errorMessage;

  String get recordingElapsedLabel {
    final minutes = (recordingElapsedSec ~/ 60).toString().padLeft(2, '0');
    final seconds = (recordingElapsedSec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  HomeState copyWith({
    bool? isRecording,
    String? currentPath,
    List<Session>? sessions,
    int? lastCreatedSessionId,
    int? recordingElapsedSec,
    String? errorMessage,
    bool clearError = false,
    bool clearLastCreatedSessionId = false,
  }) {
    return HomeState(
      isRecording: isRecording ?? this.isRecording,
      currentPath: currentPath ?? this.currentPath,
      sessions: sessions ?? this.sessions,
      lastCreatedSessionId: clearLastCreatedSessionId
          ? null
          : (lastCreatedSessionId ?? this.lastCreatedSessionId),
      recordingElapsedSec: recordingElapsedSec ?? this.recordingElapsedSec,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  DateTime? _sessionStartedAt;
  Timer? _recordingTimer;

  @override
  HomeState build() {
    ref.onDispose(_stopRecordingTimer);
    Future.microtask(_loadSessions);
    return const HomeState();
  }

  Future<void> _loadSessions() async {
    final repository = ref.read(speechRepositoryProvider);
    final sessions = await repository.getSessions();
    state = state.copyWith(sessions: sessions, clearError: true);
    ref.invalidate(homeDashboardProvider);
  }

  void clearLastCreatedSessionId() {
    state = state.copyWith(clearLastCreatedSessionId: true);
  }

  void _startRecordingTimer() {
    _stopRecordingTimer();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(recordingElapsedSec: state.recordingElapsedSec + 1);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<void> refresh() => _loadSessions();

  Future<void> toggleRecording() async {
    final recordingService = ref.read(recordingServiceProvider);
    final repository = ref.read(speechRepositoryProvider);

    try {
      if (!state.isRecording) {
        final path = await recordingService.resolveRecordingPath();
        await recordingService.startRecording(path);
        _sessionStartedAt = DateTime.now();

        state = state.copyWith(
          isRecording: true,
          currentPath: path,
          recordingElapsedSec: 0,
          clearError: true,
          clearLastCreatedSessionId: true,
        );
        _startRecordingTimer();
        return;
      }

      _stopRecordingTimer();
      final savedPath = await recordingService.stopRecording();
      final endedAt = DateTime.now();
      final startedAt = _sessionStartedAt ?? endedAt;
      final audioPath = savedPath ?? state.currentPath;

      final sessionId = await repository.createSession(
        Session(
          startedAt: startedAt,
          endedAt: endedAt,
          durationMs: endedAt.difference(startedAt).inMilliseconds,
          audioPath: audioPath,
        ),
      );

      _sessionStartedAt = null;
      final sessions = await repository.getSessions();
      ref.invalidate(homeDashboardProvider);

      state = state.copyWith(
        isRecording: false,
        currentPath: audioPath,
        sessions: sessions,
        lastCreatedSessionId: sessionId,
        recordingElapsedSec: 0,
        clearError: true,
      );
    } catch (error) {
      _stopRecordingTimer();
      state = state.copyWith(
        isRecording: false,
        recordingElapsedSec: 0,
        errorMessage: error.toString(),
      );
    }
  }
}

final homeViewModelProvider =
    NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);
