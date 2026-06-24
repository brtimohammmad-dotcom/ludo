import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_service.g.dart';

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;
  String? _lastAssetPath;

  AudioService() {
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    final bool isLocalhost = Uri.base.host.contains('localhost') || Uri.base.host.isEmpty;
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

  // 🟢 متد جدید و چندکاناله برای پخش همزمان افکت‌های صوتی
  Future<void> playSFX(String assetPath) async {
    if (_isMuted) return;

    try {
      final bool isLocalhost = Uri.base.host.contains('localhost') || Uri.base.host.isEmpty;
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

      // ⚡ ساخت یک پلیر اختصاصی و موقت برای این افکت صوتی خاص
      final AudioPlayer temporarySfxPlayer = AudioPlayer();

      await temporarySfxPlayer.setAsset(correctPath);
      await temporarySfxPlayer.setVolume(1.0);

      // پخش صدا به صورت آتش‌وبرافروز (Fire and Forget)
      temporarySfxPlayer.play();

      // 🧹 مدیریت حافظه: به محض اینکه پخش صدا تمام شد، پلیر دیسپوز می‌شود تا حافظه آزاد شود
      temporarySfxPlayer.processingStateStream.listen((state) async {
        if (state == ProcessingState.completed) {
          await temporarySfxPlayer.dispose();
        }
      });

    } catch (e) {
      debugPrint("🎵 SFX Multi-channel Notice: $e");
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _bgmPlayer.setVolume(_isMuted ? 0.0 : 0.2);
  }
}

@Riverpod(keepAlive: true)
AudioService audioService(Ref ref) {
  return AudioService();
}