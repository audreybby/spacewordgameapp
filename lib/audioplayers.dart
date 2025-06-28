import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _bgPlayer = AudioPlayer()
    ..setPlayerMode(PlayerMode.mediaPlayer);
  bool _isPlaying = false;
  double _volume = 0.5;

  factory AudioService() => _instance;

  AudioService._internal() {
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('music_volume') ?? 0.5;
    await _bgPlayer.setVolume(_volume);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    if (!_isPlaying) {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.setVolume(_volume);
      await _bgPlayer.play(AssetSource(assetPath));
      _isPlaying = true;
    }
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _bgPlayer.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', _volume);
  }

  Future<void> stopMusic() async {
    if (_isPlaying) {
      await _bgPlayer.stop();
      _isPlaying = false;
    }
  }

  void dispose() {
    _bgPlayer.dispose();
  }
}
