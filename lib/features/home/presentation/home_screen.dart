import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/models/session.dart';
import '../../../services/providers/app_providers.dart';
import '../../session_detail/presentation/session_detail_screen.dart';
import 'home_view_model.dart';
import 'widgets/progress_chart.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ref.listen<HomeState>(homeViewModelProvider, (previous, next) {
      final sessionId = next.lastCreatedSessionId;
      if (sessionId == null || sessionId == previous?.lastCreatedSessionId) {
        return;
      }
      ref.read(homeViewModelProvider.notifier).clearLastCreatedSessionId();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionDetailScreen(sessionId: sessionId),
        ),
      );
    });

    final state = ref.watch(homeViewModelProvider);
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('VoiceCode', style: AppFonts.inter()),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (dashboard) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!dashboard.asrAvailable)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2010),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Text(
                    'Install ASR for full transcripts: pip install faster-whisper',
                    style: AppFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Communication',
                      value: dashboard.latestScore != null
                          ? dashboard.latestScore!.toStringAsFixed(0)
                          : '—',
                      suffix: dashboard.latestScore != null ? '/100' : '',
                      accent: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'Streak',
                      value: '${dashboard.streakDays}',
                      suffix: ' days',
                      accent: const Color(0xFF81C784),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Progress',
                style: AppFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 8),
              ProgressChart(history: dashboard.scoreHistory),
              const SizedBox(height: 16),
              if (state.isRecording)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: theme.colorScheme.error, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Recording ${state.recordingElapsedLabel}',
                        style: AppFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                'Recent sessions',
                style: AppFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: state.sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No sessions yet. Tap Start Session.',
                          style: AppFonts.inter(color: theme.hintColor),
                        ),
                      )
                    : ListView.separated(
                        itemCount: state.sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _SessionTile(session: state.sessions[index]);
                        },
                      ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref
                      .read(homeViewModelProvider.notifier)
                      .toggleRecording(),
                  icon: Icon(state.isRecording
                      ? Icons.stop_rounded
                      : Icons.fiber_manual_record),
                  label: Text(
                      state.isRecording ? 'Stop Session' : 'Start Session'),
                  style: state.isRecording
                      ? ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.accent,
  });

  final String label;
  final String value;
  final String suffix;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppFonts.inter(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: AppFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = session.startedAt.toLocal().toString().split('.').first;

    return InkWell(
      onTap: session.id == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      SessionDetailScreen(sessionId: session.id!),
                ),
              ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session #${session.id ?? '?'}',
                    style: AppFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  Text(time,
                      style: AppFonts.inter(
                          fontSize: 11, color: theme.hintColor)),
                ],
              ),
            ),
            if (session.overallScore != null)
              Text(
                session.overallScore!.toStringAsFixed(0),
                style: AppFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
