import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../../core/models/silence_region.dart';

/// Deterministic silence detection from 16-bit PCM WAV files.
abstract final class AudioSilenceDetector {
  static const double minSilenceDurationSec = 0.5;
  static const int frameMs = 20;
  static const double energyThresholdRatio = 0.02;

  static Future<List<SilenceRegion>> detect(String audioPath) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      return const [];
    }

    final bytes = await file.readAsBytes();
    if (bytes.length < 44) {
      return const [];
    }

    final sampleRate = _readSampleRate(bytes);
    if (sampleRate <= 0) {
      return const [];
    }

    final pcm = _extractMonoPcm16(bytes);
    if (pcm.isEmpty) {
      return const [];
    }

    final frameSize = max(1, (sampleRate * frameMs) ~/ 1000);
    final energies = <double>[];

    for (var i = 0; i < pcm.length; i += frameSize) {
      final end = min(i + frameSize, pcm.length);
      var sum = 0.0;
      for (var j = i; j < end; j++) {
        sum += pcm[j] * pcm[j];
      }
      energies.add(sqrt(sum / (end - i)));
    }

    if (energies.isEmpty) {
      return const [];
    }

    final peak = energies.reduce(max);
    if (peak == 0) {
      return [
        SilenceRegion(startMs: 0, endMs: (pcm.length * 1000 ~/ sampleRate)),
      ];
    }

    final threshold = peak * energyThresholdRatio;
    final minSilentFrames = max(1, (minSilenceDurationSec * 1000 / frameMs).round());

    final silences = <SilenceRegion>[];
    var silentRun = 0;
    var silentStartFrame = 0;

    for (var i = 0; i < energies.length; i++) {
      final isSilent = energies[i] <= threshold;
      if (isSilent) {
        if (silentRun == 0) {
          silentStartFrame = i;
        }
        silentRun++;
      } else if (silentRun >= minSilentFrames) {
        silences.add(
          SilenceRegion(
            startMs: silentStartFrame * frameMs,
            endMs: i * frameMs,
          ),
        );
        silentRun = 0;
      } else {
        silentRun = 0;
      }
    }

    if (silentRun >= minSilentFrames) {
      silences.add(
        SilenceRegion(
          startMs: silentStartFrame * frameMs,
          endMs: energies.length * frameMs,
        ),
      );
    }

    return silences;
  }

  static int _readSampleRate(Uint8List bytes) {
    if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF') {
      return 0;
    }
    return bytes.buffer.asByteData().getUint32(24, Endian.little);
  }

  static List<double> _extractMonoPcm16(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    var offset = 12;
    var audioFormat = 1;
    var numChannels = 1;
    var bitsPerSample = 16;
    var dataOffset = -1;
    var dataSize = 0;

    while (offset + 8 <= bytes.length) {
      final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final chunkDataOffset = offset + 8;

      if (chunkId == 'fmt ') {
        audioFormat = data.getUint16(chunkDataOffset, Endian.little);
        numChannels = data.getUint16(chunkDataOffset + 2, Endian.little);
        bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
      } else if (chunkId == 'data') {
        dataOffset = chunkDataOffset;
        dataSize = chunkSize;
        break;
      }

      offset += 8 + chunkSize;
    }

    if (dataOffset < 0 || audioFormat != 1 || bitsPerSample != 16) {
      return const [];
    }

    final samples = <double>[];
    final end = min(dataOffset + dataSize, bytes.length);
    for (var i = dataOffset; i + 1 < end; i += 2 * numChannels) {
      final sample = data.getInt16(i, Endian.little);
      samples.add(sample / 32768.0);
    }

    return samples;
  }
}
