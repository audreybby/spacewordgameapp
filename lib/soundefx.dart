import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundEffects {
  SoundEffects._privateConstructor(); // hanya satu konstruktor
  static final SoundEffects _instance = SoundEffects._privateConstructor();
  factory SoundEffects() => _instance;

  double _volume = 0.5;

  // Panggil ini setelah instance dibuat
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _volume = prefs.getDouble('sound_volume') ?? 0.5;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_volume', _volume);
  }

  Future<void> playEffect(String filename) async {
    final player = AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setVolume(_volume);
    await player.play(AssetSource('sound/$filename'));
  }

  Future<void> click() => playEffect('click.mp3');
  Future<void> pop() => playEffect('pop.mp3');
  Future<void> win() => playEffect('win.mp3');
  Future<void> lose() => playEffect('lose.mp3');
}
