import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves a writable app data folder without native path_provider plugins.
Future<String> resolveAppSupportDirectory() async {
  if (Platform.isWindows) {
    final appData = Platform.environment['APPDATA'];
    if (appData != null && appData.isNotEmpty) {
      final dir = Directory(p.join(appData, 'VoiceCode'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }
  }

  if (Platform.isLinux) {
    final xdg = Platform.environment['XDG_DATA_HOME'];
    final base = (xdg != null && xdg.isNotEmpty)
        ? xdg
        : p.join(Platform.environment['HOME'] ?? '.', '.local', 'share');
    final dir = Directory(p.join(base, 'VoiceCode'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  if (Platform.isMacOS) {
    final home = Platform.environment['HOME'];
    if (home != null && home.isNotEmpty) {
      final dir = Directory(
        p.join(home, 'Library', 'Application Support', 'VoiceCode'),
      );
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir.path;
    }
  }

  final fallback = Directory(p.join(Directory.systemTemp.path, 'VoiceCode'));
  if (!await fallback.exists()) {
    await fallback.create(recursive: true);
  }
  return fallback.path;
}
