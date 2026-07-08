import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  bool _isMuted = false;
  String? _lastAssetPath;

  AudioService() {
    // ⚡ تنظیم پیش‌فرض مسیر فایل‌های صوتی برای فلیم
    // اگر فایل‌هایت مستقیماً داخل آستس هستند این را خالی '' بگذار
    FlameAudio.audioCache.prefix = '';

    // مقداردهی اولیه و آماده‌سازی سیستم موزیک پس‌زمینه فلیم
    FlameAudio.bgm.initialize();
  }

  /// بارگذاری موازی و کش کردن تمام صداها (هم افکت‌ها و هم موزیک پس‌زمینه) در حافظه RAM
  Future<void> initAudioCache(List<String> sfxAssets, {String? bgmAsset}) async {
    try {
      // تمیز کردن لیست آدرس‌ها بر اساس ساختار وب/لوکال‌هاست شما
      List<String> allAssetsToCache = sfxAssets.map((path) => _getCorrectPath(path)).toList();

      if (bgmAsset != null) {
        allAssetsToCache.add(_getCorrectPath(bgmAsset));
      }

      // 🟢 لود و دیکود کردن تمام فایل‌های صوتی به صورت یکجا در RAM مرورگر
      await FlameAudio.audioCache.loadAll(allAssetsToCache);
      debugPrint("⚡ FlameAudio: All Audio resources preloaded into Web Audio API successfully!");
    } catch (e) {
      debugPrint("🎵 FlameAudio Cache Error: $e");
    }
  }

  String _getCorrectPath(String assetPath) {
    final bool isLocalhost =
        Uri.base.host.contains('localhost') || Uri.base.host.isEmpty;
    String correctPath = assetPath;

    if (isLocalhost) {
      if (correctPath.startsWith('assets/')) {
        correctPath = correctPath.replaceFirst('assets/', '');
      }
    } else {
      if (!correctPath.startsWith('assets/')) {
        correctPath = 'assets/$correctPath';
      }
    }
    return correctPath;
  }

  /// 🟢 پخش موزیک پس‌زمینه به صورت لوپ (Loop) با تاخیر صفر و حجم صدای ملایم
  Future<void> playBackgroundMusic(String assetPath) async {
    String correctPath = _getCorrectPath(assetPath);

    // اگر همین موزیک در حال پخش است، کاری نکن
    if (_lastAssetPath == correctPath && FlameAudio.bgm.isPlaying) return;

    try {
      _lastAssetPath = correctPath;

      // متد play در ماژول bgm صدا را به صورت خودکار لوپ (LoopMode.all) می‌کند
      await FlameAudio.bgm.play(
        correctPath,
        volume: _isMuted ? 0.0 : 0.2,
      );
    } catch (e) {
      debugPrint("🎵 FlameAudio BGM Error: $e");
    }
  }

  /// متوقف کردن موزیک پس‌زمینه
  Future<void> stopBackgroundMusic() async {
    if (FlameAudio.bgm.isPlaying) {
      await FlameAudio.bgm.stop();
    }
  }

  /// ⚡ شلیک آنی و همزمان افکت صوتی (SFX) بدون تاخیر
  void playSFX(String assetPath) {
    if (_isMuted) return;

    try {
      String correctPath = _getCorrectPath(assetPath);
      // فلیم خودش خروجی چندکاناله ایجاد می‌کند و صداها بدون قطع شدن روی هم لایه می‌خورند
      FlameAudio.play(correctPath);
    } catch (e) {
      debugPrint("🎵 FlameAudio SFX Play Error: $e");
    }
  }

  /// مدیریت قطع و وصل صدا (Mute / Unmute) کل بازی
  void toggleMute() {
    _isMuted = !_isMuted;

    if (_isMuted) {
      // میوت کردن موزیک پس‌زمینه
      FlameAudio.bgm.audioPlayer.setVolume(0.0);
      // نکته: افکت‌های صوتی در متد playSFX با چک کردن پرچم _isMuted جلوی پخششان گرفته می‌شود
    } else {
      // آن‌میوت کردن و بازگرداندن صدا به ولوم قبلی
      FlameAudio.bgm.audioPlayer.setVolume(0.2);
    }
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  return AudioService();
}