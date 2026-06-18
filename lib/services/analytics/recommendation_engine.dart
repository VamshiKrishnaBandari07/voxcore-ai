import '../../core/models/session_metrics.dart';

/// A training task recommendation derived from session metrics.
class TrainingRecommendation {
  const TrainingRecommendation({
    required this.title,
    required this.description,
    required this.focusArea,
  });

  final String title;
  final String description;
  final String focusArea;
}

/// Rule-based recommendation engine — deterministic, no LLM.
class RecommendationEngine {
  List<TrainingRecommendation> recommend(SessionMetrics metrics) {
    if (metrics.totalWordCount == 0 && metrics.overallScore == 0) {
      return const [
        TrainingRecommendation(
          title: 'Record a longer sample',
          description:
              'Speak for at least 20 seconds so VoiceCode can measure your delivery.',
          focusArea: 'recording',
        ),
      ];
    }

    final recommendations = <TrainingRecommendation>[];

    if (metrics.wpm > 165) {
      recommendations.add(
        const TrainingRecommendation(
          title: 'Slow down your pace',
          description:
              'Your active WPM is above target. Practice pause drills and read at 130 WPM.',
          focusArea: 'pace',
        ),
      );
    } else if (metrics.wpm > 0 && metrics.wpm < 110) {
      recommendations.add(
        const TrainingRecommendation(
          title: 'Increase speaking energy',
          description:
              'Your pace is below conversational range. Practice short pitch segments at 130–150 WPM.',
          focusArea: 'pace',
        ),
      );
    }

    if (metrics.fillerDensity > 0.06) {
      recommendations.add(
        TrainingRecommendation(
          title: 'Reduce filler words',
          description:
              'Filler density is ${(metrics.fillerDensity * 100).toStringAsFixed(1)}%. Pause silently instead of saying "um" or "like".',
          focusArea: 'fluency',
        ),
      );
    }

    if (metrics.pacingStability > 350) {
      recommendations.add(
        const TrainingRecommendation(
          title: 'Stabilize your rhythm',
          description:
              'Word timing varies significantly. Use metronome pacing exercises at a steady rate.',
          focusArea: 'articulation',
        ),
      );
    }

    if (metrics.breath < 60) {
      recommendations.add(
        const TrainingRecommendation(
          title: 'Improve breath placement',
          description:
              'Add deliberate pauses between phrases. Practice sentence-chunking breath drills.',
          focusArea: 'breath',
        ),
      );
    }

    if (metrics.clarity < 70) {
      recommendations.add(
        const TrainingRecommendation(
          title: 'Sharpen clarity',
          description:
              'Over-articulate consonants and open vowels in slow reading practice.',
          focusArea: 'clarity',
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        TrainingRecommendation(
          title: 'Strong session',
          description:
              'Communication score ${metrics.overallScore.toStringAsFixed(0)}/100. Keep practicing to maintain consistency.',
          focusArea: 'maintenance',
        ),
      );
    }

    return recommendations.take(3).toList();
  }
}
