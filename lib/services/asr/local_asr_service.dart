import 'dart:isolate';

import '../../core/models/asr_result.dart';
import 'asr_isolate_worker.dart';
import 'asr_service.dart';

/// Runs local ASR inside a background isolate to keep the UI responsive.
class LocalAsrService implements AsrService {
  @override
  Future<AsrResult> transcribe(String audioPath) {
    return Isolate.run(() => transcribeInIsolate(audioPath));
  }
}
