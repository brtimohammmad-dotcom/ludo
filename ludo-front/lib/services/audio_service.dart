import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  // تعریف دو پلier مجزا برای موزیک پس‌زمینه و افکت‌ها
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMuted = false;
  bool _isBgmLoading = false; // قفل برای جلوگیری از تداخل لود مرورگر (Abort Error)
  String? _currentBgmPath;    // ذخیره آخرین آدرس پخش شده

  AudioService() {
    // تنظیم لوپ بومی برای موزیک پس‌زمینه
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  // ۱. پخش موزیک پس‌زمینه (سازگار با وب، لوکال و سرور Render)
  Future<void> playBackgroundMusic(String assetPath) async {
    // اصلاح آدرس برای ساختار بیلد فلاتر وب روی سرور رندر (تولید لایه assets/assets/)
    final String correctPath = assetPath.startsWith('assets/')
        ? assetPath
        : 'assets/$assetPath';

    // اگر همین الان این موزیک در حال پخش یا لود است، درخواست تکراری را نادیده بگیر
    if (_currentBgmPath == correctPath && (_bgmPlayer.playing || _isBgmLoading)) {
      return;
    }

    if (_isBgmLoading) return;

    try {
      _isBgmLoading = true;
      _currentBgmPath = correctPath;

      // توقف امن پلیر قبل از لود فایل جدید
      if (_bgmPlayer.playing) {
        await _bgmPlayer.stop();
      }

      // لود کردن فایل از آدرس اصلاح شده
      await _bgmPlayer.setAsset(correctPath);

      // مدیریت ولوم بر اساس وضعیت Mute
      if (_isMuted) {
        await _bgmPlayer.setVolume(0.0);
      } else {
        await _bgmPlayer.setVolume(1.0);
      }

      // پخش نهایی (اگر در این فاصله کاربر آدرس را عوض نکرده باشد)
      if (_currentBgmPath == correctPath) {
        _bgmPlayer.play();
      }
    } catch (e) {
      debugPrint("⚠️ Web Audio Load Handled (Abort Avoided): $e");
    } finally {
      _isBgmLoading = false;
    }
  }

  // توقف موزیک پس‌زمینه
  Future<void> stopBackgroundMusic() async {
    try {
      if (_bgmPlayer.playing) {
        await _bgmPlayer.stop();
      }
    } catch (e) {
      debugPrint("❌ Error stopping BG music: $e");
    }
  }

  // ۲. پخش افکت‌های صوتی کوتاه (تاس، حرکت مهره و...) بدون قطع کردن موزیک اصلی
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

  // مدیریت قطع و وصل کردن کل صداهای بازی (Mute/Unmute)
  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 1.0);
    _sfxPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }

  bool get isMuted => _isMuted;

  // آزاد کردن حافظه و بستن امن استریم‌ها در وب
  void dispose() {
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