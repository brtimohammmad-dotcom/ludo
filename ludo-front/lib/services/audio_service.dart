import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // 🟢 ایمپورت پکیج جدید
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  // تعریف دو پلیر مجزا از نوع AudioPlayer پکیج just_audio
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;

  // پخش موزیک پس‌زمینه (لوپ)
  Future<void> playBackgroundMusic(String assetPath) async {
    try {

      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.all); // 🟢 تنظیم لوپ به صورت بومی

      if (_isMuted) {
        await _bgmPlayer.setVolume(0.0);
      } else {
        await _bgmPlayer.setVolume(1.0);
      }

      // پخش مستقیم بدون مسدود کردن ترد اصلی
      _bgmPlayer.play();
    } catch (e) {
      debugPrint("❌ Error playing BG music: $e");
    }
  }

  // توقف موزیک پس‌زمینه
  Future<void> stopBackgroundMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint("❌ Error stopping BG music: $e");
    }
  }

  // پخش افکت‌های صوتی کوتاه (تاس، حرکت و...)
  Future<void> playSFX(String assetPath) async {
    if (_isMuted) return;

    try {

      // لود آنی و پخش افکت صوتی
      await _sfxPlayer.setAsset(assetPath);
      _sfxPlayer.play();
    } catch (e) {
      debugPrint("❌ Error playing SFX: $e");
    }
  }

  // مدیریت قطع و وصل کردن صدا (Mute/Unmute)
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _bgmPlayer.setVolume(0.0);
      _sfxPlayer.setVolume(0.0);
    } else {
      _bgmPlayer.setVolume(1.0);
      _sfxPlayer.setVolume(1.0);
    }
  }

  bool get isMuted => _isMuted;

  // آزاد کردن حافظه پلیرها
  void dispose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

@riverpod
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}