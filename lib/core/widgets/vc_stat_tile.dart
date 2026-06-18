import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';

class VcStatTile extends StatelessWidget {
  const VcStatTile({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final String? suffix;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.inter(fontSize: 12, color: theme.hintColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: AppFonts.inter(fontSize: 14, color: theme.hintColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
