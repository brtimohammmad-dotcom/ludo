import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

// -----------------------------------------------------------------------------
// لایه ارتباط مستقیم و بدون واسطه با جاوااسکریپت (Howler.js) برای سرعت فضایی
// -----------------------------------------------------------------------------
@JS('Howl')
extension type Howl._(JSObject _) implements JSObject {
  external Howl(HowlOptions options);
  external void play();
  external void stop();
  external void volume(double vol);
}

@JS()
@anonymous
extension type HowlOptions._(JSObject _) implements JSObject {
  external factory HowlOptions({
    JSArray<JSString> src,
    bool loop,
    double volume,
    bool preload,
  });
}
// -----------------------------------------------------------------------------

class AudioService {
  final Map<String, Howl> _cachedHowls = {};
  Howl? _bgmHowl;

  bool _isMuted = false;
  String? _lastBgmPath;

  AudioService();

  /// تابع کمکی برای تصحیح مسیر آستس‌ها متناسب با خروجی وب فلاتر در تلگرام
  String _fixAssetPath(String path) {
    // حذف اسلش ابتدایی در صورت وجود
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // اگر مسیر از قبل شامل دبل آستس نبود، آن را اصلاح کن
    if (!cleanPath.startsWith('assets/assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/', 'assets/assets/');
    }
    return cleanPath;
  }

  /// ⚡ لود صوتی مستقیم در رم مرورگر با اصلاح خودکار مسیرهای 404 وب
  Future<void> initAudioCache(List<String> sfxAssets, {String? bgmAsset}) async {
    try {
      // کش کردن صداهای تک‌ضرب (SFX) با اولویت پرفورمنس بالا
      for (final asset in sfxAssets) {
        if (_cachedHowls.containsKey(asset)) continue;

        final webPath = _fixAssetPath(asset);
        final howl = Howl(HowlOptions(
          src: [webPath.toJS].toJS,
          loop: false,
          volume: 0.3,
          preload: true,
        ));
        _cachedHowls[asset] = howl;
      }

      // آماده‌سازی موزیک پس‌زمینه
      if (bgmAsset != null && _bgmHowl == null) {
        final webBgmPath = _fixAssetPath(bgmAsset);
        _bgmHowl = Howl(HowlOptions(
          src: [webBgmPath.toJS].toJS,
          loop: true,
          volume: 0.12,
          preload: true,
        ));
        _cachedHowls[bgmAsset] = _bgmHowl!;
      }

      debugPrint("🚀 Blazing Fast Web Audio (Howler) initialized with fixed paths!");
    } catch (e) {
      debugPrint("❌ Web Audio Init Error: $e");
    }
  }

  /// 🔥 شلیک آنی صدا بدون کوچک‌ترین تاخیر (مشابه سیستم صوتی Flame)
  void playSFX(String assetPath) {
    if (_isMuted) return;

    final howl = _cachedHowls[assetPath];
    if (howl != null) {
      howl.play();
    } else {
      // لود آنی با مسیر اصلاح‌شده در صورت فراموشی کش اولیه
      final webPath = _fixAssetPath(assetPath);
      final newHowl = Howl(HowlOptions(
        src: [webPath.toJS].toJS,
        loop: false,
        volume: 0.3,
      ));
      _cachedHowls[assetPath] = newHowl;
      newHowl.play();
    }
  }

  /// پخش و لوپ موزیک پس‌زمینه بدون ایجاد گلوگاه پردازشی
  Future<void> playBackgroundMusic(String assetPath) async {
    if (_lastBgmPath == assetPath) return;
    _lastBgmPath = assetPath;

    try {
      _bgmHowl?.stop();

      final howl = _cachedHowls[assetPath];
      if (howl != null) {
        _bgmHowl = howl;
      } else {
        final webPath = _fixAssetPath(assetPath);
        _bgmHowl = Howl(HowlOptions(
          src: [webPath.toJS].toJS,
          loop: true,
          volume: _isMuted ? 0.0 : 0.13,
        ));
        _cachedHowls[assetPath] = _bgmHowl!;
      }

      _bgmHowl!.volume(_isMuted ? 0.0 : 0.13);
      _bgmHowl!.play();
    } catch (e) {
      debugPrint("🎵 Web Audio BGM Error: $e");
    }
  }

  /// متوقف کردن موزیک بک‌گراند
  Future<void> stopBackgroundMusic() async {
    _bgmHowl?.stop();
    _lastBgmPath = null;
  }

  /// میوت و آن‌میوت آنی و سراسری در سطح مرورگر
  void toggleMute() {
    _isMuted = !_isMuted;

    // تغییر ولوم موزیک پس‌زمینه
    _bgmHowl?.volume(_isMuted ? 0.0 : 0.2);

    // تغییر ولوم تمام افکت‌های صوتی موجود در کش
    _cachedHowls.forEach((_, howl) {
      if (howl != _bgmHowl) {
        howl.volume(_isMuted ? 0.0 : 1.0);
      }
    });
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  return AudioService();
}