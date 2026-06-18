import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../platform/app_paths.dart';

class AppSettings {
  const AppSettings({
    this.defaultPlaybackSpeed = 1.0,
    this.showTips = true,
    this.dailyGoalMinutes = 10,
  });

  final double defaultPlaybackSpeed;
  final bool showTips;
  final int dailyGoalMinutes;

  AppSettings copyWith({
    double? defaultPlaybackSpeed,
    bool? showTips,
    int? dailyGoalMinutes,
  }) {
    return AppSettings(
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      showTips: showTips ?? this.showTips,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultPlaybackSpeed': defaultPlaybackSpeed,
        'showTips': showTips,
        'dailyGoalMinutes': dailyGoalMinutes,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultPlaybackSpeed: (json['defaultPlaybackSpeed'] as num?)?.toDouble() ?? 1.0,
      showTips: json['showTips'] as bool? ?? true,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 10,
    );
  }
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _fileName = 'settings.json';

  @override
  Future<AppSettings> build() async => _load();

  Future<AppSettings> _load() async {
    try {
      final dir = await resolveAppSupportDirectory();
      final file = File('$dir/$_fileName');
      if (!await file.exists()) return const AppSettings();
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> _save(AppSettings settings) async {
    final dir = await resolveAppSupportDirectory();
    final file = File('$dir/$_fileName');
    await file.writeAsString(jsonEncode(settings.toJson()));
    state = AsyncData(settings);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(defaultPlaybackSpeed: speed));
  }

  Future<void> setShowTips(bool value) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(showTips: value));
  }

  Future<void> setDailyGoal(int minutes) async {
    final current = state.value ?? const AppSettings();
    await _save(current.copyWith(dailyGoalMinutes: minutes));
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
