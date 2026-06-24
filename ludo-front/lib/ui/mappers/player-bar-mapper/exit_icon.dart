import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/utils/alerts/exit_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class ExitIcon extends ConsumerWidget {
  const ExitIcon({
    super.key,
    required this.boardSize,
  });

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameControllerProvider.notifier);

    return GestureDetector(
      onTap: () {
        ref.read(audioServiceProvider).playSFX(
          'assets/audio/sound-effect/exit_button_sound.wav',
        );
        showAnimatedDialog(
          context: context,
          child: ExitButtonAlert(gameController: gameController),
        );
      },
      child: Icon(
        Icons.exit_to_app_rounded,
        color: Colors.black38,
        size: boardSize * 0.06,
      ),
    );
  }
}