import '../../core/models/asr_result.dart';
import 'asr_isolate_worker.dart';
import 'asr_service.dart';

/// Runs local ASR on the main isolate (Windows cannot spawn subprocesses in isolates).
class LocalAsrService implements AsrService {
  @override
  Future<AsrResult> transcribe(String audioPath) {
    return transcribeInIsolate(audioPath);
  }
}
