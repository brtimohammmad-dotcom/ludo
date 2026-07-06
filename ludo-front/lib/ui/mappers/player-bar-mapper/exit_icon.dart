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
    final buttonSize = boardSize * 0.055; 

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
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.logout_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: buttonSize * 0.55,
          ),
        ),
      ),
    );
  }
}