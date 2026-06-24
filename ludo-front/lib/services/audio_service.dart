import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'audio_service.g.dart';

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  bool _isMuted = false;
  String? _lastAssetPath;

  AudioService() {
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    // هماهنگی با ساختار پوشه assets/assets در رندر
    final String correctPath = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';

    // 🟢 اگر این موزیک از قبل در حال پخش است، دوباره لودش نکن تا ارور abort رخ ندهد
    if (_lastAssetPath == correctPath && _bgmPlayer.playing) return;

    try {
      _lastAssetPath = correctPath;

      // لود امن و پخش
      await _bgmPlayer.setAsset(correctPath);
      await _bgmPlayer.setVolume(_isMuted ? 0.0 : 1.0);
      _bgmPlayer.play();
    } catch (e) {
      // ارورهای احتمالی وب را بدون کرش کردن مدیریت کن
      debugPrint("🎵 Audio Web Notice: $e");
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_bgmPlayer.playing) {
      await _bgmPlayer.stop();
    }
  }

  Future<void> playSFX(String assetPath) async {
    if (_isMuted) return;
    try {
      final String correctPath = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';
      await _sfxPlayer.setAsset(correctPath);
      _sfxPlayer.play();
    } catch (e) {
      debugPrint("🎵 SFX Notice: $e");
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    _sfxPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }
}

// 🟢 با این کار سرویس صدا در تمام طول بازی زنده می‌ماند و بی‌دلیل نابود نمی‌شود
@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  return AudioService();
}