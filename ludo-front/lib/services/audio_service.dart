import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

// -----------------------------------------------------------------------------
// لایه ارتباط مستقیم و بدون واسطه با جاوااسکریپت (Howler.js)
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

@Riverpod(keepAlive: true)
class AudioService extends _$AudioService {
  final Map<String, Howl> _cachedHowls = {};
  Howl? _bgmHowl;
  String? _lastBgmPath;

  // ولوم‌های استاندارد (بازه 0.0 تا 1.0)
  static const double _defaultSfxVolume = 0.3;
  static const double _defaultBgmVolume = 0.13;

  @override
  bool build() {
    return false;
  }

  /// گتر برای دسترسی مستقیم در صورت نیاز
  bool get isMuted => state;

  /// تابع کمکی برای تصحیح مسیر آستس‌ها متناسب با خروجی وب فلاتر
  String _fixAssetPath(String path) {
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (!cleanPath.startsWith('assets/assets/')) {
      cleanPath = cleanPath.replaceFirst('assets/', 'assets/assets/');
    }
    return cleanPath;
  }

  /// ⚡ لود صوتی مستقیم در رم مرورگر
  Future<void> initAudioCache(
      List<String> sfxAssets, {
        String? bgmAsset,
      }) async {
    try {
      for (final asset in sfxAssets) {
        if (_cachedHowls.containsKey(asset)) continue;

        final webPath = _fixAssetPath(asset);
        final howl = Howl(
          HowlOptions(
            src: [webPath.toJS].toJS,
            loop: false,
            volume: state ? 0.0 : _defaultSfxVolume,
            preload: true,
          ),
        );
        _cachedHowls[asset] = howl;
      }

      if (bgmAsset != null && _bgmHowl == null) {
        final webBgmPath = _fixAssetPath(bgmAsset);
        _bgmHowl = Howl(
          HowlOptions(
            src: [webBgmPath.toJS].toJS,
            loop: true,
            volume: state ? 0.0 : _defaultBgmVolume,
            preload: true,
          ),
        );
        _cachedHowls[bgmAsset] = _bgmHowl!;
      }

      debugPrint(
        "🚀 Blazing Fast Web Audio (Howler) initialized with fixed paths!",
      );
    } catch (e) {
      debugPrint("❌ Web Audio Init Error: $e");
    }
  }

  /// 🔥 شلیک آنی صدا
  void playSFX(String assetPath) {
    if (state) return; // اگر میوت است پخش نکن

    final howl = _cachedHowls[assetPath];
    if (howl != null) {
      howl.volume(_defaultSfxVolume);
      howl.play();
    } else {
      final webPath = _fixAssetPath(assetPath);
      final newHowl = Howl(
        HowlOptions(
          src: [webPath.toJS].toJS,
          loop: false,
          volume: _defaultSfxVolume,
        ),
      );
      _cachedHowls[assetPath] = newHowl;
      newHowl.play();
    }
  }

  /// پخش و لوپ موزیک پس‌زمینه
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
        _bgmHowl = Howl(
          HowlOptions(
            src: [webPath.toJS].toJS,
            loop: true,
            volume: state ? 0.0 : _defaultBgmVolume,
          ),
        );
        _cachedHowls[assetPath] = _bgmHowl!;
      }

      _bgmHowl!.volume(state ? 0.0 : _defaultBgmVolume);
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
    // تغییر وضعیت State در Riverpod
    state = !state;

    final double bgmVol = state ? 0.0 : _defaultBgmVolume;
    final double sfxVol = state ? 0.0 : _defaultSfxVolume;

    // تغییر ولوم موزیک پس‌زمینه
    _bgmHowl?.volume(bgmVol);

    // تغییر درست ولوم تمام افکت‌های صوتی موجود در کش به ولوم استاندارد 0.3
    _cachedHowls.forEach((_, howl) {
      if (howl != _bgmHowl) {
        howl.volume(sfxVol);
      }
    });
  }
}