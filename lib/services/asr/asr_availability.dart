import 'dart:io';

/// Checks whether local ASR (faster_whisper via Python) is available.
abstract final class AsrAvailability {
  static bool? _cached;

  static Future<bool> isAvailable() async {
    if (_cached != null) return _cached!;

    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      _cached = false;
      return false;
    }

    final python = Platform.isWindows ? 'python' : 'python3';
    try {
      final result = await Process.run(
        python,
        ['-c', 'import faster_whisper; print("ok")'],
      );
      _cached = result.exitCode == 0 && result.stdout.toString().contains('ok');
    } catch (_) {
      _cached = false;
    }

    return _cached!;
  }

  static void resetCache() => _cached = null;
}
