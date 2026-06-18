import 'package:flutter/material.dart';

import '../../../core/theme/app_fonts.dart';
import '../data/conversation_scenarios.dart';
import 'co_friend_screen.dart';

class ScenarioPickerScreen extends StatelessWidget {
  const ScenarioPickerScreen({super.key});

  IconData _iconFor(String name) => switch (name) {
        'work' => Icons.work_outline_rounded,
        'coffee' => Icons.local_cafe_outlined,
        'present' => Icons.slideshow_outlined,
        _ => Icons.chat_bubble_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a co-friend topic', style: AppFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Practice like talking with a friend — they ask, you answer, they respond.',
            style: AppFonts.inter(color: theme.hintColor, height: 1.4),
          ),
          const SizedBox(height: 20),
          for (final scenario in conversationScenarios)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => CoFriendScreen(scenarioId: scenario.id),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _iconFor(scenario.iconName),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scenario.title,
                                style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'With ${scenario.friendName} · ${scenario.turns.length} turns',
                                style: AppFonts.inter(fontSize: 12, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                scenario.description,
                                style: AppFonts.inter(fontSize: 13, color: theme.hintColor),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
