import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../conversation/presentation/scenario_picker_screen.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../session_detail/presentation/session_detail_screen.dart';

class PracticeTab extends ConsumerStatefulWidget {
  const PracticeTab({super.key});

  @override
  ConsumerState<PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends ConsumerState<PracticeTab> {
  bool _soloMode = false;

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

    if (_soloMode) {
      return _SoloPractice(onBack: () => setState(() => _soloMode = false));
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text('Practice', style: AppFonts.inter(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(
          'Choose how you want to practice English today.',
          style: AppFonts.inter(color: theme.hintColor, height: 1.4),
        ),
        const SizedBox(height: 24),
        _ModeCard(
          icon: Icons.groups_rounded,
          title: 'Practice with a co-friend',
          subtitle: 'Take turns — they ask, you answer, they respond. Like real conversation.',
          accent: theme.colorScheme.primary,
          badge: 'Recommended',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ScenarioPickerScreen()),
          ),
        ),
        const SizedBox(height: 14),
        _ModeCard(
          icon: Icons.mic_rounded,
          title: 'Solo recording',
          subtitle: 'Record one long session and get full metrics.',
          accent: theme.colorScheme.tertiary,
          onTap: () => setState(() => _soloMode = true),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withOpacity(0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: AppFonts.inter(fontWeight: FontWeight.w800, fontSize: 17)),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge!,
                              style: AppFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: accent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: AppFonts.inter(fontSize: 13, color: theme.hintColor, height: 1.35)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoloPractice extends ConsumerWidget {
  const _SoloPractice({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);
    final recording = state.isRecording;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
              Text('Solo recording', style: AppFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
            ],
          ),
          const Spacer(),
          if (recording)
            Text('Recording ${state.recordingElapsedLabel}',
                style: AppFonts.inter(fontWeight: FontWeight.w800, color: theme.colorScheme.error)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ref.read(homeViewModelProvider.notifier).toggleRecording(),
            child: Container(
              width: recording ? 120 : 150,
              height: recording ? 120 : 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: recording ? theme.colorScheme.error : theme.colorScheme.tertiary,
              ),
              child: Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(recording ? 'Tap to stop' : 'Start session', style: AppFonts.inter(fontWeight: FontWeight.w600)),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
