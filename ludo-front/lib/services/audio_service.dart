import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  // برای جلوگیری از لود همزمان و تداخل در وب
  bool _isBgmLoading = false;

  AudioService() {
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    // ۱. اگر پلیر در حال لود کردن موزیک است، درخواست جدید را نادیده بگیر
    if (_isBgmLoading) return;

    try {
      _isBgmLoading = true;

      // ساخت آدرس دو تایی assets/assets مخصوص سرور رندر
      final String correctPath = assetPath.startsWith('assets/')
          ? assetPath
          : 'assets/$assetPath';

      // ۲. قبل از لود موزیک جدید، اگر موزیکی در حال پخش است آن را متوقف کن
      if (_bgmPlayer.playing) {
        await _bgmPlayer.stop();
      }

      await _bgmPlayer.setAsset(correctPath);

      if (_isMuted) {
        await _bgmPlayer.setVolume(0.0);
      } else {
        await _bgmPlayer.setVolume(1.0);
      }

      // ۳. چک کن که پلیر در این فاصله دیسپوز یا بسته نشده باشد
      _bgmPlayer.play();
    } catch (e) {
      debugPrint("❌ Error playing BG music: $e");
    } finally {
      _isBgmLoading = false;
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if (_bgmPlayer.playing) {
        await _bgmPlayer.stop();
      }
    } catch (e) {
      debugPrint("❌ Error stopping BG music: $e");
    }
  }

  Future<void> playSFX(String assetPath) async {
    if (_isMuted) return;

    try {
      final String correctPath = assetPath.startsWith('assets/')
          ? assetPath
          : 'assets/$assetPath';

      await _sfxPlayer.setAsset(correctPath);
      _sfxPlayer.play();
    } catch (e) {
      debugPrint("❌ Error playing SFX: $e");
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    _sfxPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }

  bool get isMuted => _isMuted;

  // ۴. متد دیسپوز اصلاح شده برای لایه وب
  void dispose() {
    // در وب بهتر است ابتدا استاپ شوند و بعد دیسپوز
    _bgmPlayer.stop().then((_) => _bgmPlayer.dispose());
    _sfxPlayer.stop().then((_) => _sfxPlayer.dispose());
  }
}

@riverpod
AudioService audioService(Ref ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
}