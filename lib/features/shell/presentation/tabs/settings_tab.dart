import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/platform/app_paths.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/widgets/vc_option_tile.dart';
import '../../../../services/providers/app_providers.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final asrAsync = ref.watch(asrAvailableProvider);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        Text('Settings', style: AppFonts.inter(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Customize VoiceCode for your workflow.', style: AppFonts.inter(color: theme.hintColor)),
        const SizedBox(height: 24),
        Text('Playback', style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        settingsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
          data: (settings) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [0.75, 1.0, 1.25, 1.5].map((speed) {
              final selected = settings.defaultPlaybackSpeed == speed;
              return ChoiceChip(
                label: Text('${speed}x'),
                selected: selected,
                onSelected: (_) => ref.read(appSettingsProvider.notifier).setPlaybackSpeed(speed),
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                labelStyle: AppFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: selected ? theme.colorScheme.primary : theme.hintColor,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),
        Text('Preferences', style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        settingsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (settings) => VcOptionTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Coaching tips',
            subtitle: 'Show recommendations after each session',
            trailing: Switch(
              value: settings.showTips,
              onChanged: (v) => ref.read(appSettingsProvider.notifier).setShowTips(v),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('System', style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        asrAsync.when(
          loading: () => VcOptionTile(
            icon: Icons.translate_rounded,
            title: 'Speech-to-text',
            subtitle: 'Checking…',
          ),
          error: (_, __) => VcOptionTile(
            icon: Icons.translate_rounded,
            title: 'Speech-to-text',
            subtitle: 'Unavailable',
          ),
          data: (ready) => VcOptionTile(
            icon: Icons.translate_rounded,
            title: 'Speech-to-text (ASR)',
            subtitle: ready ? 'faster-whisper installed' : 'Run: pip install faster-whisper',
            trailing: Icon(
              ready ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
              color: ready ? theme.colorScheme.secondary : const Color(0xFFFFB74D),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<String>(
          future: resolveAppSupportDirectory(),
          builder: (context, snap) => VcOptionTile(
            icon: Icons.folder_outlined,
            title: 'Data folder',
            subtitle: snap.data ?? 'Loading…',
          ),
        ),
        const SizedBox(height: 10),
        VcOptionTile(
          icon: Icons.mic_external_on_rounded,
          title: 'Microphone access',
          subtitle: 'Settings → Privacy → Microphone → allow desktop apps',
          onTap: () => _openMicSettings(context),
        ),
        const SizedBox(height: 24),
        Text('About', style: AppFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
        const SizedBox(height: 10),
        VcOptionTile(
          icon: Icons.info_outline_rounded,
          title: 'VoiceCode',
          subtitle: 'v1.0 · Offline speech practice for Windows',
        ),
        const SizedBox(height: 10),
        VcOptionTile(
          icon: Icons.refresh_rounded,
          title: 'Refresh dashboard',
          subtitle: 'Reload scores and session list',
          onTap: () {
            ref.invalidate(homeDashboardProvider);
            ref.invalidate(scoreHistoryProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dashboard refreshed')),
            );
          },
        ),
      ],
    );
  }

  void _openMicSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Open Windows Settings → Privacy → Microphone')),
    );
  }
}
