import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/models/transcript.dart';
import '../../../services/audio/session_audio_player_service.dart';
import '../../../services/providers/app_providers.dart';
import '../../home/presentation/home_view_model.dart';
import 'session_detail_view_model.dart';
import 'widgets/enriched_transcript_view.dart';
import 'widgets/metrics_dashboard.dart';
import 'widgets/processing_overlay.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/session_audio_player_bar.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<SessionDetailScreen> createState() =>
      _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  bool _audioLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartPipeline();
      _loadAudio();
    });
  }

  void _maybeStartPipeline() {
    final state = ref.read(sessionDetailViewModelProvider(widget.sessionId));
    if (!state.isInitialized) return;

    final status = state.processingStatus;
    final hasAudio = state.session?.audioPath?.isNotEmpty ?? false;

    if (hasAudio && status.needsProcessing) {
      ref
          .read(sessionDetailViewModelProvider(widget.sessionId).notifier)
          .runProcessingPipeline();
    }
  }

  Future<void> _loadAudio() async {
    final session =
        ref.read(sessionDetailViewModelProvider(widget.sessionId)).session;
    final path = session?.audioPath;
    if (path == null || path.isEmpty || _audioLoaded) return;

    await ref.read(sessionAudioPlayerProvider(widget.sessionId)).load(path);
    if (mounted) setState(() => _audioLoaded = true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This removes the recording and all analysis.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await ref
        .read(sessionDetailViewModelProvider(widget.sessionId).notifier)
        .deleteSession();
    await ref.read(homeViewModelProvider.notifier).refresh();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionDetailViewModelProvider(widget.sessionId), (prev, next) {
      if (prev?.isInitialized == false && next.isInitialized) {
        _maybeStartPipeline();
        _loadAudio();
      }
      if (next.processingStage == ProcessingStage.completed) {
        _loadAudio();
      }
    });

    final detailState =
        ref.watch(sessionDetailViewModelProvider(widget.sessionId));
    final processingStatus =
        ref.watch(processingStatusProvider(widget.sessionId));
    final metricsAsync = ref.watch(metricsProvider(widget.sessionId));
    final transcriptAsync = ref.watch(transcriptProvider(widget.sessionId));
    final recommendations =
        ref.watch(recommendationsProvider(widget.sessionId));
    final player = ref.watch(sessionAudioPlayerProvider(widget.sessionId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Session #${widget.sessionId}',
          style: AppFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _TranscriptSection(
                  transcriptAsync: transcriptAsync,
                  processingStatus: processingStatus,
                  recommendations: recommendations,
                  player: player,
                ),
              ),
              if (detailState.session?.audioPath != null)
                SessionAudioPlayerBar(player: player),
              metricsAsync.when(
                loading: () => const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (metrics) {
                  if (metrics == null) return const SizedBox(height: 180);
                  return MetricsDashboard(metrics: metrics);
                },
              ),
            ],
          ),
          if (processingStatus.isOverlayVisible)
            ProcessingOverlay(
              status: processingStatus,
              onRetry: () => ref
                  .read(sessionDetailViewModelProvider(widget.sessionId)
                      .notifier)
                  .runProcessingPipeline(),
            ),
        ],
      ),
    );
  }
}

class _TranscriptSection extends StatelessWidget {
  const _TranscriptSection({
    required this.transcriptAsync,
    required this.processingStatus,
    required this.recommendations,
    required this.player,
  });

  final AsyncValue<Transcript?> transcriptAsync;
  final ProcessingStatus processingStatus;
  final List<TrainingRecommendationDisplay> recommendations;
  final SessionAudioPlayerService player;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return transcriptAsync.when(
      loading: () => Center(
        child: Text('Loading…',
            style: AppFonts.inter(color: theme.hintColor)),
      ),
      error: (error, _) => Center(
        child: Text(error.toString(),
            style: AppFonts.inter(color: theme.colorScheme.error)),
      ),
      data: (transcript) {
        if (transcript?.enrichedText == null ||
            transcript!.enrichedText!.isEmpty) {
          return Center(
            child: Text(
              processingStatus.isActive
                  ? 'Processing your speech…'
                  : 'Transcript will appear after analysis.',
              style: AppFonts.inter(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommendations.isNotEmpty) ...[
                Text(
                  'Recommended next steps',
                  style: AppFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                for (final rec in recommendations)
                  RecommendationCard(
                    title: rec.title,
                    description: rec.description,
                  ),
                const SizedBox(height: 16),
              ],
              Text(
                'Enriched transcript',
                style: AppFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap underlined words to seek playback',
                style: AppFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.primary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              EnrichedTranscriptView(
                enrichedText: transcript.enrichedText!,
                wordTimestamps: transcript.wordTimestamps,
                onWordTap: (word) => player.seekToWordAndPlay(word.startMs),
              ),
            ],
          ),
        );
      },
    );
  }
}
