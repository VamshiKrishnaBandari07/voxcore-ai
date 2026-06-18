import 'package:flutter/material.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../services/audio/session_audio_player_service.dart';

class SessionAudioPlayerBar extends StatefulWidget {
  const SessionAudioPlayerBar({super.key, required this.player});

  final SessionAudioPlayerService player;

  @override
  State<SessionAudioPlayerBar> createState() => _SessionAudioPlayerBarState();
}

class _SessionAudioPlayerBarState extends State<SessionAudioPlayerBar> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoaded = false;
  double _speed = 1.0;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    widget.player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    widget.player.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _duration = duration;
          _isLoaded = true;
        });
      }
    });
    widget.player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
  }

  Future<void> _setSpeed(double speed) async {
    await widget.player.setSpeed(speed);
    if (mounted) setState(() => _speed = speed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: !_isLoaded
                    ? null
                    : () {
                        if (_isPlaying) {
                          widget.player.pause();
                        } else {
                          widget.player.play();
                        }
                      },
                icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: theme.colorScheme.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: !_isLoaded
                            ? null
                            : (value) {
                                final targetMs =
                                    (_duration.inMilliseconds * value).round();
                                widget.player.seekToMs(targetMs);
                              },
                      ),
                    ),
                    Text(
                      '${_format(_position)} / ${_format(_duration)}',
                      style: AppFonts.inter(
                          fontSize: 11, color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _speeds.map((speed) {
                final selected = _speed == speed;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text('${speed}x'),
                    selected: selected,
                    onSelected: !_isLoaded ? null : (_) => _setSpeed(speed),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
