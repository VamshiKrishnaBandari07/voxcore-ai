import '../../core/models/asr_result.dart';
import '../../core/models/processed_transcript.dart';
import '../../core/models/word_timestamp.dart';

/// Deterministic transcript enrichment (pause / stress markers).
abstract final class TranscriptEnricher {
  static const double pauseThresholdSec = 0.5;
  static const double longPauseThresholdSec = 1.0;

  static ProcessedTranscript enrich(AsrResult asrResult) {
    final rawText = _buildRawTranscript(asrResult);
    final enrichedText = _buildEnrichedTranscript(asrResult);

    return ProcessedTranscript(
      rawText: rawText,
      enrichedText: enrichedText,
      asrResult: asrResult,
    );
  }

  static String _buildRawTranscript(AsrResult asrResult) {
    if (asrResult.words.isNotEmpty) {
      return asrResult.words.map((w) => w.word).join(' ').trim();
    }
    return asrResult.fullText.trim();
  }

  static String _buildEnrichedTranscript(AsrResult asrResult) {
    if (asrResult.words.isEmpty) {
      return _enrichSilenceOnly(asrResult);
    }

    final buffer = StringBuffer();

    for (var i = 0; i < asrResult.words.length; i++) {
      final word = asrResult.words[i];

      if (i > 0) {
        final gapSec = _gapSeconds(asrResult.words[i - 1], word);
        if (gapSec >= pauseThresholdSec) {
          buffer.write('[PAUSE] ');
        }
      }

      buffer.write(word.word);

      if (_endsSentence(word.word) && i < asrResult.words.length - 1) {
        final gapSec = _gapSeconds(word, asrResult.words[i + 1]);
        if (gapSec >= longPauseThresholdSec) {
          buffer.write(' //');
        } else if (gapSec >= pauseThresholdSec) {
          buffer.write(' /');
        }
      }

      if (i < asrResult.words.length - 1) {
        buffer.write(' ');
      }
    }

    return _injectStandalonePauses(buffer.toString().trim(), asrResult);
  }

  static String _enrichSilenceOnly(AsrResult asrResult) {
    if (asrResult.silences.isEmpty) {
      return rawTextOrPlaceholder(asrResult);
    }

    return asrResult.silences
        .map((s) => '[PAUSE ${s.durationSec.toStringAsFixed(1)}s]')
        .join(' ');
  }

  static String rawTextOrPlaceholder(AsrResult asrResult) {
    if (asrResult.fullText.isNotEmpty) {
      return asrResult.fullText;
    }
    return '(no speech detected)';
  }

  static String _injectStandalonePauses(String text, AsrResult asrResult) {
    for (final silence in asrResult.silences) {
      if (silence.durationSec < pauseThresholdSec) {
        continue;
      }

      final midSec = (silence.startMs + silence.endMs) / 2000.0;
      if (!_hasPauseNear(text, midSec, asrResult)) {
        text = '$text [PAUSE]';
      }
    }

    return text.trim();
  }

  static bool _hasPauseNear(String text, double midSec, AsrResult asrResult) {
    if (!text.contains('[PAUSE]')) {
      return false;
    }

    for (var i = 0; i < asrResult.words.length - 1; i++) {
      final gapMid =
          (asrResult.words[i].endSec + asrResult.words[i + 1].startSec) / 2;
      if ((gapMid - midSec).abs() < 0.25) {
        return true;
      }
    }

    return false;
  }

  static bool _endsSentence(String word) {
    return RegExp(r'[.!?]$').hasMatch(word.trim());
  }

  static double _gapSeconds(WordTimestamp left, WordTimestamp right) {
    return (right.startMs - left.endMs) / 1000.0;
  }
}
