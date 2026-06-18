import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/session.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../home/presentation/home_view_model.dart';
import '../../../session_detail/presentation/session_detail_screen.dart';

class HistoryTab extends ConsumerWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(homeViewModelProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text('History', style: AppFonts.inter(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            '${state.sessions.length} sessions saved on this device',
            style: AppFonts.inter(color: theme.hintColor),
          ),
          const SizedBox(height: 20),
          if (state.sessions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Icon(Icons.history_rounded, size: 48, color: theme.hintColor),
                  const SizedBox(height: 12),
                  Text(
                    'No sessions yet',
                    style: AppFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Go to Practice and start your first session.',
                    style: AppFonts.inter(fontSize: 13, color: theme.hintColor),
                  ),
                ],
              ),
            )
          else
            ...state.sessions.map((s) => _SessionCard(session: s)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = session.startedAt.toLocal().toString().split('.').first;
    final duration = session.durationMs != null
        ? '${(session.durationMs! / 1000).round()}s'
        : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: session.id == null
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SessionDetailScreen(sessionId: session.id!),
                    ),
                  ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.graphic_eq_rounded, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session #${session.id ?? '?'}',
                          style: AppFonts.inter(fontWeight: FontWeight.w700)),
                      Text(time, style: AppFonts.inter(fontSize: 12, color: theme.hintColor)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (session.overallScore != null)
                      Text(
                        session.overallScore!.toStringAsFixed(0),
                        style: AppFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    Text(duration, style: AppFonts.inter(fontSize: 11, color: theme.hintColor)),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: theme.hintColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
