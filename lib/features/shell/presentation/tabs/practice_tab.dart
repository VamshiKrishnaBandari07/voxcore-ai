import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../session_detail/presentation/session_detail_screen.dart';

class PracticeTab extends ConsumerStatefulWidget {
  const PracticeTab({super.key});

  @override
  ConsumerState<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends ConsumerState<PracticeTab> {
  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      final sessionId = next.lastCreatedSessionId;
      if (sessionId == null || sessionId == previous?.lastCreatedSessionId) return;
      ref.read(homeViewModelProvider.notifier).clearLastCreatedSessionId();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionDetailScreen(sessionId: sessionId),
        ),
      );
    });

    final state = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);
    final recording = state.isRecording;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        children: [
          Text(
            'Practice',
            style: AppFonts.inter(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            recording
                ? 'Speak naturally. We analyze clarity, pace, and fillers.'
                : 'Tap the button below to start a new session.',
            textAlign: TextAlign.center,
            style: AppFonts.inter(color: theme.hintColor, height: 1.4),
          ),
          const Spacer(),
          if (recording)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record, color: theme.colorScheme.error, size: 14),
                  const SizedBox(width: 10),
                  Text(
                    'Recording ${state.recordingElapsedLabel}',
                    style: AppFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: () => ref.read(homeViewModelProvider.notifier).toggleRecording(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: recording ? 120 : 160,
              height: recording ? 120 : 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recording ? theme.colorScheme.error : theme.colorScheme.primary,
                border: Border.all(
                  color: (recording ? theme.colorScheme.error : theme.colorScheme.primary)
                      .withOpacity(0.4),
                  width: 8,
                ),
              ),
              child: Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                size: recording ? 48 : 56,
                color: recording ? Colors.white : const Color(0xFF001014),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            recording ? 'Tap to stop' : 'Start session',
            style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const Spacer(flex: 2),
          if (state.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.errorMessage!,
                style: AppFonts.inter(fontSize: 12, color: theme.colorScheme.error),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _TipChip(label: 'Speak for 30–90 sec'),
              _TipChip(label: 'Quiet room helps'),
              _TipChip(label: 'Natural pace'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(label, style: AppFonts.inter(fontSize: 12, color: theme.hintColor)),
    );
  }
}
