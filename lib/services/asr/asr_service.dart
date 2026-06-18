import '../../core/models/asr_result.dart';

/// Contract for offline, on-device speech-to-text.
abstract class AsrService {
  /// Transcribes [audioPath] locally. Must be safe to call from a background isolate.
  Future<AsrResult> transcribe(String audioPath);
}
