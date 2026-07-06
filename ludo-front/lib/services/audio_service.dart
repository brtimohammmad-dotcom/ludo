import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;
  String? _lastAssetPath;

  final Map<String, List<AudioPlayer>> _sfxCache = {};
  final int _maxConcurrentPlayers = 3;

  AudioService() {
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  Future<void> initAudioCache(List<String> sfxAssets) async {
    List<Future<void>> cacheTasks = [];

    for (String assetPath in sfxAssets) {
      String correctPath = _getCorrectPath(assetPath);
      _sfxCache[assetPath] = [];

      for (int i = 0; i < _maxConcurrentPlayers; i++) {
        final player = AudioPlayer();
        _sfxCache[assetPath]!.add(player);

        // وظیفه لود شدن را بدون await درون لیست می‌ریزیم تا موازی اجرا شوند
        cacheTasks.add(
          player
              .setAsset(correctPath)
              .then((_) => player.setVolume(1.0))
              .catchError((e) {
                debugPrint("🎵 Error caching SFX ($assetPath): $e");
              }),
        );
      }
    }

    // حالا منتظر می‌مونیم تا همه صداها با هم در پس‌زمینه لود بشن
    await Future.wait(cacheTasks);
    debugPrint("⚡ Audio cache completed in parallel!");
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

  Future<void> playBackgroundMusic(String assetPath) async {
    String correctPath = _getCorrectPath(assetPath);
    if (_lastAssetPath == correctPath && _bgmPlayer.playing) return;

    try {
      _lastAssetPath = correctPath;
      await _bgmPlayer.setAsset(correctPath);
      await _bgmPlayer.setVolume(_isMuted ? 0.0 : 0.2);
      _bgmPlayer.play();
    } catch (e) {
      debugPrint("🎵 Audio Web Notice: $e");
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_bgmPlayer.playing) {
      await _bgmPlayer.stop();
    }
  }

  void playSFX(String assetPath) async {
    // ⚡ اضافه کردن async برای کار با متدهای کنترل پلیر
    if (_isMuted) return;

    final players = _sfxCache[assetPath];
    if (players == null || players.isEmpty) {
      debugPrint("⚠️ Sound $assetPath was not preloaded!");
      return;
    }

    AudioPlayer? availablePlayer;
    for (var player in players) {
      if (!player.playing) {
        availablePlayer = player;
        break;
      }
    }

    // اگر همه پلیرها مشغول بودند، قدیمی‌ترین پلیر (اولین پلیر لیست) را برمی‌داریم
    if (availablePlayer == null) {
      availablePlayer = players.first;
      // 🛑 کلید حل مشکل: چون پلیر در حال پخش است، اول آن را استاپ می‌کنیم تا ریست شود
      await availablePlayer.stop();
    }

    try {
      await availablePlayer.seek(Duration.zero); // بازگشت به ابتدای فایل صوتی
      availablePlayer.play(); // پخش مجدد و بدون مشکل
    } catch (e) {
      debugPrint("🎵 SFX Playback Error: $e");
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 0.2);

    _sfxCache.forEach((key, players) {
      for (var player in players) {
        player.setVolume(_isMuted ? 0.0 : 1.0);
      }
    });
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  return AudioService();
}
