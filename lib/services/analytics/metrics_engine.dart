import 'dart:math';

import '../../core/models/asr_result.dart';
import '../../core/models/processed_transcript.dart';
import '../../core/models/session_metrics.dart';
import '../../core/models/silence_region.dart';
import '../../core/models/word_timestamp.dart';

/// Deterministic metrics engine — pure math, no LLM involvement.
class MetricsEngine {
  static const Set<String> _fillerWords = {
    'um', 'uh', 'uhh', 'umm', 'like', 'ah', 'er', 'erm',
    'hmm', 'hm', 'yeah', 'so', 'well', 'actually', 'basically',
    'literally', 'you know',
  };

  static const double _idealWpmMin = 120;
  static const double _idealWpmMax = 160;

  SessionMetrics compute({
    required ProcessedTranscript processed,
    int? totalFileDurationMs,
  }) {
    return computeFromAsr(
      asrResult: processed.asrResult,
      totalFileDurationMs: totalFileDurationMs,
    );
  }

  SessionMetrics computeFromAsr({
    required AsrResult asrResult,
    int? totalFileDurationMs,
  }) {
    final totalWords = asrResult.words.length;

    if (totalWords == 0 && asrResult.silences.isEmpty) {
      return SessionMetrics.neutral();
    }

    final fileDurationMs = _resolveFileDurationMs(
      asrResult: asrResult,
      totalFileDurationMs: totalFileDurationMs,
    );

    if (fileDurationMs <= 0) {
      return SessionMetrics.neutral();
    }

    final totalSilenceMs = _sumSilenceMs(asrResult.silences);
    final speakingDurationMs = max(0, fileDurationMs - totalSilenceMs);

    final wpm = speakingDurationMs > 0
        ? totalWords / (speakingDurationMs / 60000.0)
        : 0.0;

    final fluencyRatio =
        (1 - (totalSilenceMs / fileDurationMs)).clamp(0.0, 1.0) * 100;

    final fillerCount = _countFillers(asrResult.words);
    final fillerDensity = totalWords > 0 ? fillerCount / totalWords : 0.0;
    final pacingStability = _pacingStabilityStdDev(asrResult.words);

    final clarity = _scoreClarity(fillerDensity, totalWords);
    final pronunciation = _scorePronunciation(totalWords, asrResult.words);
    final fluency = _scoreFluency(fluencyRatio, fillerDensity);
    final articulation = _scoreArticulation(pacingStability, wpm);
    final pace = _scorePace(wpm);
    final breath = _scoreBreath(totalSilenceMs, fileDurationMs, totalWords);

    final overallScore = (clarity * 0.25) +
        (pronunciation * 0.20) +
        (fluency * 0.20) +
        (articulation * 0.15) +
        (pace * 0.10) +
        (breath * 0.10);

    return SessionMetrics(
      wpm: _sanitize(wpm),
      fluencyRatio: _sanitize(fluencyRatio),
      fillerDensity: _sanitize(fillerDensity),
      pacingStability: _sanitize(pacingStability),
      totalWordCount: totalWords,
      fillerCount: fillerCount,
      totalFileDurationMs: fileDurationMs,
      totalSilenceMs: totalSilenceMs,
      speakingDurationMs: speakingDurationMs,
      clarity: _sanitize(clarity),
      pronunciation: _sanitize(pronunciation),
      fluency: _sanitize(fluency),
      articulation: _sanitize(articulation),
      pace: _sanitize(pace),
      breath: _sanitize(breath),
      overallScore: _sanitize(overallScore),
    );
  }

  static double _scoreClarity(double fillerDensity, int wordCount) {
    if (wordCount == 0) return 0;
    return (100 - (fillerDensity * 200).clamp(0, 100)).clamp(0, 100).toDouble();
  }

  static double _scorePronunciation(int wordCount, List<WordTimestamp> words) {
    if (wordCount == 0) return 0;
    final avgConfidence = words
            .where((w) => w.confidence != null)
            .map((w) => w.confidence!)
            .fold(0.0, (a, b) => a + b) /
        max(1, words.where((w) => w.confidence != null).length);
    if (avgConfidence > 0) {
      return (avgConfidence * 100).clamp(0, 100);
    }
    return min(100, 40 + wordCount * 2.0);
  }

  static double _scoreFluency(double fluencyRatio, double fillerDensity) {
    final fillerPenalty = (fillerDensity * 100).clamp(0, 40);
    return (fluencyRatio - fillerPenalty).clamp(0, 100);
  }

  static double _scoreArticulation(double pacingStability, double wpm) {
    if (wpm <= 0) return 0;
    final stabilityPenalty = (pacingStability / 15).clamp(0, 50);
    return (100 - stabilityPenalty).clamp(0, 100).toDouble();
  }

  static double _scorePace(double wpm) {
    if (wpm <= 0) return 0;
    if (wpm >= _idealWpmMin && wpm <= _idealWpmMax) return 100;
    if (wpm < _idealWpmMin) {
      return max(0, 100 - (_idealWpmMin - wpm) * 1.5);
    }
    return max(0, 100 - (wpm - _idealWpmMax) * 1.2);
  }

  static double _scoreBreath(int silenceMs, int fileMs, int wordCount) {
    if (fileMs <= 0 || wordCount == 0) return 0;
    final silenceRatio = silenceMs / fileMs;
    if (silenceRatio >= 0.08 && silenceRatio <= 0.25) return 100;
    if (silenceRatio < 0.08) {
      return max(0, 100 - ((0.08 - silenceRatio) * 500));
    }
    return max(0, 100 - ((silenceRatio - 0.25) * 300));
  }

  static int _resolveFileDurationMs({
    required AsrResult asrResult,
    required int? totalFileDurationMs,
  }) {
    if (totalFileDurationMs != null && totalFileDurationMs > 0) {
      return totalFileDurationMs;
    }
    var maxEndMs = 0;
    for (final word in asrResult.words) {
      maxEndMs = max(maxEndMs, word.endMs);
    }
    for (final silence in asrResult.silences) {
      maxEndMs = max(maxEndMs, silence.endMs);
    }
    return maxEndMs;
  }

  static int _sumSilenceMs(List<SilenceRegion> silences) {
    var total = 0;
    for (final silence in silences) {
      total += max(0, silence.endMs - silence.startMs);
    }
    return total;
  }

  static int _countFillers(List<WordTimestamp> words) {
    var count = 0;
    for (final word in words) {
      final normalized = word.word
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z\s]'), '')
          .trim();
      if (normalized.isNotEmpty && _fillerWords.contains(normalized)) {
        count++;
      }
    }
    return count;
  }

  static double _pacingStabilityStdDev(List<WordTimestamp> words) {
    if (words.length < 2) return 0;
    final intervals = <double>[];
    for (var i = 1; i < words.length; i++) {
      intervals.add((words[i].startMs - words[i - 1].startMs).toDouble());
    }
    return _standardDeviation(intervals);
  }

  static double _standardDeviation(List<double> values) {
    if (values.length < 2) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    var sumSquaredDiff = 0.0;
    for (final value in values) {
      final diff = value - mean;
      sumSquaredDiff += diff * diff;
    }
    return sqrt(sumSquaredDiff / values.length);
  }

  static double _sanitize(double value) {
    if (value.isNaN || value.isInfinite) return 0;
    return value;
  }
}
