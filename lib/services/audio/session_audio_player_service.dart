import 'package:just_audio/just_audio.dart';

class SessionAudioPlayerService {
  SessionAudioPlayerService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  double _speed = 1.0;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  double get speed => _speed;

  Future<void> load(String filePath) async {
    await _player.setFilePath(filePath);
    await _player.setSpeed(_speed);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setSpeed(speed);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> seekToMs(int milliseconds) {
    return _player.seek(Duration(milliseconds: milliseconds));
  }

  Future<void> seekToWordAndPlay(int startMs) async {
    await seekToMs(startMs);
    await play();
  }

  Future<void> dispose() => _player.dispose();
}
