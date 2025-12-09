// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Singleton (uma única instância para o app todo)
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playMusic() async {
    if (_isPlaying) return;
    
    // Configura para tocar em loop infinito
    _player.setReleaseMode(ReleaseMode.loop);
    
    // Toca o arquivo local
    await _player.play(AssetSource('sounds/bg_music.mp3'), volume: 0.3); // Volume baixo
    _isPlaying = true;
  }

  Future<void> stopMusic() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> toggleMusic() async {
    if (_isPlaying) {
      await stopMusic();
    } else {
      await playMusic();
    }
  }

  bool get isPlaying => _isPlaying;
}