import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/models/session_metrics.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key, required this.history});

  final List<ScoreHistoryPoint> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (history.length < 2) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Text(
          'Complete 2+ sessions to see progress',
          style: AppFonts.inter(fontSize: 12, color: theme.hintColor),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.dividerColor,
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < history.length; i++)
                  FlSpot(i.toDouble(), history[i].score),
              ],
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
