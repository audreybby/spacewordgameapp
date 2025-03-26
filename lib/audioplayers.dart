import 'package:audioplayers/audioplayers.dart';
import 'dart:developer';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false; // Menandakan apakah musik sedang diputar

  factory AudioService() {
    return _instance;
  }

  AudioService._internal();

  // Memulai musik latar jika belum diputar
  Future<void> playBackgroundMusic(String filePath) async {
    if (!_isPlaying) {
      try {
        await _audioPlayer.play(AssetSource(filePath));
        _audioPlayer
            .setReleaseMode(ReleaseMode.loop); // Musik akan terus berulang
        _isPlaying = true;
        log('Musik latar berhasil diputar!');
      } catch (e) {
        log('Gagal memutar musik latar: $e');
      }
    }
  }

  // Menghentikan musik jika sedang diputar
  Future<void> stopMusic() async {
    if (_isPlaying) {
      try {
        await _audioPlayer.stop();
        _isPlaying = false;
        log('Musik dihentikan!');
      } catch (e) {
        log('Gagal menghentikan musik: $e');
      }
    }
  }

  // Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
