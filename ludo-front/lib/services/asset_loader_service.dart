import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/services/audio_service.dart';

final assetLoaderServiceProvider = Provider((ref) => AssetLoaderService(ref));

class AssetLoaderService {
  final Ref _ref;

  AssetLoaderService(this._ref);

  Future<void> preloadAll() async {
    await Future.wait([
      _preloadAudio(),
      _preloadLottie(),
    ]);
  }

  Future<void> _preloadAudio() async {
    final audio = _ref.read(audioServiceProvider.notifier);
    await audio.initAudioCache([
      'assets/audio/sound-effect/current_turn_sound.wav',
      'assets/audio/sound-effect/dice_rolling.wav',
      'assets/audio/sound-effect/exit_button_sound.wav',
      'assets/audio/sound-effect/friend_button_sound.wav',
      'assets/audio/sound-effect/kick_token.wav',
      'assets/audio/sound-effect/move_token.wav',
      'assets/audio/sound-effect/target_token.wav',
      'assets/audio/sound-effect/winner_sound.wav',
    ]);
  }

  Future<void> _preloadLottie() async {
    try {
      final assetLottie = AssetLottie("assets/lotties/happy-dice.lottie");
      await assetLottie.load();
    } catch (e) {
      debugPrint("🖼️ Error caching lottie: $e");
    }
  }
}