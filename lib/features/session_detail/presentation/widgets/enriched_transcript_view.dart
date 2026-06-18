import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/models/word_timestamp.dart';

/// Interactive enriched transcript with highlighted pause markers.
class EnrichedTranscriptView extends StatefulWidget {
  const EnrichedTranscriptView({
    super.key,
    required this.enrichedText,
    required this.wordTimestamps,
    required this.onWordTap,
  });

  final String enrichedText;
  final List<WordTimestamp> wordTimestamps;
  final ValueChanged<WordTimestamp> onWordTap;

  @override
  State<EnrichedTranscriptView> createState() => _EnrichedTranscriptViewState();
}

class _EnrichedTranscriptViewState extends State<EnrichedTranscriptView> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _recognizers.clear();

    final baseStyle = AppFonts.inter(
      fontSize: 16,
      height: 1.65,
      color: theme.colorScheme.onSurface,
    );

    final pauseStyle = AppFonts.mono(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFB74D),
      backgroundColor: const Color(0xFF2A2010),
    );

    final markerStyle = AppFonts.mono(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.primary,
    );

    final wordStyle = baseStyle.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary.withOpacity(0.35),
    );

    final spans = _buildSpans(
      enrichedText: widget.enrichedText,
      words: widget.wordTimestamps,
      baseStyle: baseStyle,
      wordStyle: wordStyle,
      pauseStyle: pauseStyle,
      markerStyle: markerStyle,
    );

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<InlineSpan> _buildSpans({
    required String enrichedText,
    required List<WordTimestamp> words,
    required TextStyle baseStyle,
    required TextStyle wordStyle,
    required TextStyle pauseStyle,
    required TextStyle markerStyle,
  }) {
    final spans = <InlineSpan>[];
    final tokenPattern = RegExp(r'\[PAUSE[^\]]*\]|//|/|\S+|\s+');
    final matches = tokenPattern.allMatches(enrichedText);

    var wordIndex = 0;

    for (final match in matches) {
      final token = match.group(0)!;

      if (RegExp(r'^\s+$').hasMatch(token)) {
        spans.add(TextSpan(text: token, style: baseStyle));
        continue;
      }

      if (token.startsWith('[PAUSE')) {
        spans.add(TextSpan(text: token, style: pauseStyle));
        continue;
      }

      if (token == '//' || token == '/') {
        spans.add(TextSpan(text: token, style: markerStyle));
        continue;
      }

      if (wordIndex < words.length) {
        final timestamp = words[wordIndex];
        wordIndex++;

        final recognizer = TapGestureRecognizer()
          ..onTap = () => widget.onWordTap(timestamp);
        _recognizers.add(recognizer);

        spans.add(
          TextSpan(
            text: token,
            style: wordStyle,
            recognizer: recognizer,
          ),
        );
      } else {
        spans.add(TextSpan(text: token, style: baseStyle));
      }
    }

    return spans;
  }
}
