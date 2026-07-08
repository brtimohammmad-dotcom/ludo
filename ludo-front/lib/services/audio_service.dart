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

  /// ⚡ لود صوتی مستقیم در رم مرورگر (Web Audio API Buffer) - کاملاً همگام با کدهای قبلی شما
  Future<void> initAudioCache(List<String> sfxAssets, {String? bgmAsset}) async {
    try {
      // کش کردن صداهای تک‌ضرب (SFX) با اولویت پرفورمنس بالا
      for (final asset in sfxAssets) {
        if (_cachedHowls.containsKey(asset)) continue;

        final howl = Howl(HowlOptions(
          src: [asset.toJS].toJS,
          loop: false,
          volume: 1.0,
          preload: true,
        ));
        _cachedHowls[asset] = howl;
      }

      // آماده‌سازی موزیک پس‌زمینه
      if (bgmAsset != null && _bgmHowl == null) {
        _bgmHowl = Howl(HowlOptions(
          src: [bgmAsset.toJS].toJS,
          loop: true,
          volume: 0.2,
          preload: true,
        ));
        _cachedHowls[bgmAsset] = _bgmHowl!;
      }

      debugPrint("🚀 Blazing Fast Web Audio (Howler) initialized successfully for Ludo!");
    } catch (e) {
      debugPrint("❌ Web Audio Init Error: $e");
    }
  }

  /// 🔥 شلیک آنی صدا بدون کوچک‌ترین تاخیر (مشابه سیستم صوتی Flame)
  void playSFX(String assetPath) {
    if (_isMuted) return;

    final howl = _cachedHowls[assetPath];
    if (howl != null) {
      // در Howler صداها می‌توانند همزمان و روی هم بدون هیچ لگی پخش شوند
      howl.play();
    } else {
      // لود آنی در صورت فراموشی کش اولیه
      final newHowl = Howl(HowlOptions(
        src: [assetPath.toJS].toJS,
        loop: false,
        volume: 1.0,
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

      _bgmHowl = _cachedHowls[assetPath] ?? Howl(HowlOptions(
        src: [assetPath.toJS].toJS,
        loop: true,
        volume: _isMuted ? 0.0 : 0.2,
      ));

      _cachedHowls[assetPath] = _bgmHowl!;
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

    // تغییر ولوم تمام صداها در حافظه بدون پردازش سنگین فلاتر
    _bgmHowl?.volume(_isMuted ? 0.0 : 0.2);

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