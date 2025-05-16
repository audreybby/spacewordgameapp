import 'package:audioplayers/audioplayers.dart';

class SoundEffects {
  final player = AudioPlayer();

  void popSound() async {
    await player.play(AssetSource('sound/pop.mp3'));
  }

  void clickSound() async {
    await player.play(AssetSource('sound/click.mp3'));
  }

  void winSound() async {
    await player.play(AssetSource('sound/win.mp3'));
  }

  void loseSound() async {
    await player.play(AssetSource('sound/lose.mp3'));
  }
}
