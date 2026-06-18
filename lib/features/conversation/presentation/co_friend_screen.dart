import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_fonts.dart';
import '../../session_detail/presentation/session_detail_screen.dart';
import 'conversation_view_model.dart';
import 'widgets/chat_bubble.dart';

class CoFriendScreen extends ConsumerStatefulWidget {
  const CoFriendScreen({super.key, required this.scenarioId});

  final String scenarioId;

  @override
  ConsumerState<CoFriendScreen> createState() => _CoFriendScreenState();
}

class _CoFriendScreenState extends ConsumerState<CoFriendScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationViewModelProvider.notifier).startScenario(widget.scenarioId);
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(conversationViewModelProvider, (_, __) => _scrollToBottom());

    final state = ref.watch(conversationViewModelProvider);
    final theme = Theme.of(context);
    final scenario = state.scenario;
    final friendName = scenario?.friendName ?? 'Friend';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Practice with $friendName', style: AppFonts.inter(fontWeight: FontWeight.w700)),
            if (scenario != null)
              Text(
                scenario.title,
                style: AppFonts.inter(fontSize: 12, color: theme.hintColor),
              ),
          ],
        ),
        actions: [
          if (state.isComplete)
            TextButton(
              onPressed: () {
                ref.read(conversationViewModelProvider.notifier).reset();
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (state.isRecording)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              color: theme.colorScheme.error.withOpacity(0.12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: theme.colorScheme.error, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Your turn — ${state.recordingLabel}',
                    style: AppFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: state.messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return ChatBubble(
                  message: msg,
                  friendName: friendName,
                  onTapUser: msg.sessionId == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  SessionDetailScreen(sessionId: msg.sessionId!),
                            ),
                          ),
                );
              },
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                state.errorMessage!,
                style: AppFonts.inter(fontSize: 12, color: theme.colorScheme.error),
              ),
            ),
          _TurnBar(state: state),
        ],
      ),
    );
  }
}

class _TurnBar extends ConsumerWidget {
  const _TurnBar({required this.state});
  final ConversationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vm = ref.read(conversationViewModelProvider.notifier);

    if (state.isComplete) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Text(
          'Session complete. Your turns are saved in History.',
          textAlign: TextAlign.center,
          style: AppFonts.inter(color: theme.hintColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Text(
            state.isRecording
                ? 'Speak to ${state.scenario?.friendName}…'
                : state.isBusy
                    ? 'Saving your turn…'
                    : 'Tap when ready — your co-friend is listening',
            style: AppFonts.inter(fontSize: 13, color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isBusy
                  ? null
                  : state.isRecording
                      ? () => vm.stopUserTurn()
                      : state.canSpeak
                          ? () => vm.startUserTurn()
                          : null,
              icon: Icon(state.isRecording ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(
                state.isRecording
                    ? 'Finish my turn'
                    : 'Speak your turn (${(state.turnIndex + 1)}/${state.scenario?.turns.length ?? 0})',
              ),
              style: state.isRecording
                  ? ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
