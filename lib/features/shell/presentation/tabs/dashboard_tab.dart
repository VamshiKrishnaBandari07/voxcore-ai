import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/vc_stat_tile.dart';
import '../../../../services/providers/app_providers.dart';
import '../../../home/presentation/widgets/progress_chart.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final theme = Theme.of(context);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (d) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(homeDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              'Your speech coach',
              style: AppFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track clarity, fluency, and pace across every session.',
              style: AppFonts.inter(fontSize: 14, color: theme.hintColor, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: VcStatTile(
                    label: 'Communication',
                    value: d.latestScore?.toStringAsFixed(0) ?? '—',
                    suffix: d.latestScore != null ? '/100' : '',
                    icon: Icons.auto_graph_rounded,
                    accent: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VcStatTile(
                    label: 'Streak',
                    value: '${d.streakDays}',
                    suffix: ' days',
                    icon: Icons.local_fire_department_rounded,
                    accent: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            VcStatTile(
              label: 'Total sessions',
              value: '${d.sessionCount}',
              icon: Icons.library_music_rounded,
              accent: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 24),
            Text('Progress trend', style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            ProgressChart(history: d.scoreHistory),
            if (!d.asrAvailable) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2010),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate_rounded, color: Color(0xFFFFB74D)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Install faster-whisper for full transcripts: pip install faster-whisper',
                        style: AppFonts.inter(fontSize: 12, color: const Color(0xFFFFB74D)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
