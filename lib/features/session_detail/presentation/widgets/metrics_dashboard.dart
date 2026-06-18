import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/models/session_metrics.dart';

class MetricsDashboard extends StatelessWidget {
  const MetricsDashboard({super.key, required this.metrics});

  final SessionMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Metrics',
                style: AppFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: theme.hintColor,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Score ${metrics.overallScore.toStringAsFixed(0)}',
                  style: AppFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.55,
            children: [
              _MetricCard(
                label: 'WPM',
                value: metrics.wpm.toStringAsFixed(1),
                subtitle: 'Active speech rate',
                accent: theme.colorScheme.primary,
              ),
              _MetricCard(
                label: 'Fluency',
                value: '${metrics.fluencyRatio.toStringAsFixed(0)}%',
                subtitle: 'Fluency ratio',
                accent: const Color(0xFF81C784),
              ),
              _MetricCard(
                label: 'Fillers',
                value: metrics.fillerDensity.toStringAsFixed(2),
                subtitle: 'Filler density',
                accent: const Color(0xFFFFB74D),
              ),
              _MetricCard(
                label: 'Pacing σ',
                value: metrics.pacingStability.toStringAsFixed(0),
                subtitle: 'Stability (ms)',
                accent: const Color(0xFFBA68C8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: AppFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            subtitle,
            style: AppFonts.inter(fontSize: 11, color: theme.hintColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
