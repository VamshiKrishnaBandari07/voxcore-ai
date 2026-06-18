import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/session.dart';
import '../../../services/providers/app_providers.dart';
import '../data/conversation_scenarios.dart';
import '../models/conversation_models.dart';
import '../services/conversation_partner.dart';

class ConversationState {
  const ConversationState({
    this.scenario,
    this.messages = const [],
    this.turnIndex = 0,
    this.isRecording = false,
    this.recordingSec = 0,
    this.isComplete = false,
    this.isBusy = false,
    this.errorMessage,
  });

  final ConversationScenario? scenario;
  final List<ChatMessage> messages;
  final int turnIndex;
  final bool isRecording;
  final int recordingSec;
  final bool isComplete;
  final bool isBusy;
  final String? errorMessage;

  String get recordingLabel {
    final m = (recordingSec ~/ 60).toString().padLeft(2, '0');
    final s = (recordingSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get canSpeak =>
      scenario != null && !isComplete && !isRecording && !isBusy;

  bool get canStop => isRecording;

  ConversationState copyWith({
    ConversationScenario? scenario,
    List<ChatMessage>? messages,
    int? turnIndex,
    bool? isRecording,
    int? recordingSec,
    bool? isComplete,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationState(
      scenario: scenario ?? this.scenario,
      messages: messages ?? this.messages,
      turnIndex: turnIndex ?? this.turnIndex,
      isRecording: isRecording ?? this.isRecording,
      recordingSec: recordingSec ?? this.recordingSec,
      isComplete: isComplete ?? this.isComplete,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConversationViewModel extends Notifier<ConversationState> {
  final _partner = ConversationPartner();
  Timer? _timer;
  DateTime? _turnStartedAt;
  String? _currentAudioPath;

  @override
  ConversationState build() => const ConversationState();

  void startScenario(String scenarioId) {
    final scenario = scenarioById(scenarioId);
    state = ConversationState(
      scenario: scenario,
      messages: [
        ChatMessage(isFriend: true, text: _partner.openingMessage(scenario)),
      ],
      turnIndex: 0,
    );
  }

  Future<void> startUserTurn() async {
    if (!state.canSpeak) return;

    final recording = ref.read(recordingServiceProvider);
    try {
      final path = await recording.resolveRecordingPath();
      await recording.startRecording(path);
      _currentAudioPath = path;
      _turnStartedAt = DateTime.now();
      _startTimer();
      state = state.copyWith(isRecording: true, recordingSec: 0, clearError: true);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> stopUserTurn() async {
    if (!state.canStop) return;

    _stopTimer();
    state = state.copyWith(isBusy: true, isRecording: false);

    final recording = ref.read(recordingServiceProvider);
    final repository = ref.read(speechRepositoryProvider);
    final scenario = state.scenario!;

    try {
      final savedPath = await recording.stopRecording();
      final endedAt = DateTime.now();
      final startedAt = _turnStartedAt ?? endedAt;
      final audioPath = savedPath ?? _currentAudioPath;
      final durationSec = endedAt.difference(startedAt).inSeconds;

      final sessionId = await repository.createSession(
        Session(
          startedAt: startedAt,
          endedAt: endedAt,
          durationMs: endedAt.difference(startedAt).inMilliseconds,
          audioPath: audioPath,
        ),
      );

      ref.invalidate(homeDashboardProvider);

      final messages = List<ChatMessage>.from(state.messages)
        ..add(
          ChatMessage(
            isFriend: false,
            text: 'My turn (${durationSec}s)',
            durationLabel: state.recordingLabel,
            sessionId: sessionId,
          ),
        )
        ..add(
          ChatMessage(
            isFriend: true,
            text: _partner.afterUserTurn(
              scenario: scenario,
              completedTurnIndex: state.turnIndex,
              durationSec: durationSec,
            ),
          ),
        );

      final nextIndex = state.turnIndex + 1;
      final isComplete = nextIndex >= scenario.turns.length;

      if (!isComplete) {
        // Next question is already inside friendAfterUser.
      } else {
        messages.add(
          ChatMessage(
            isFriend: true,
            text: _partner.sessionComplete(scenario),
          ),
        );
      }

      state = state.copyWith(
        messages: messages,
        turnIndex: nextIndex,
        isComplete: isComplete,
        isBusy: false,
        recordingSec: 0,
        clearError: true,
      );

      _turnStartedAt = null;
      _currentAudioPath = null;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        isRecording: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    _stopTimer();
    state = const ConversationState();
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(recordingSec: state.recordingSec + 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

final conversationViewModelProvider =
    NotifierProvider<ConversationViewModel, ConversationState>(
  ConversationViewModel.new,
);
