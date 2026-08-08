import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/utils/alerts/exit_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class ExitIcon extends ConsumerWidget {
  const ExitIcon({super.key, required this.boardSize});
  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonSize = boardSize * 0.055;
    return GestureDetector(
      onTap: () {
        ref
            .read(audioServiceProvider.notifier)
            .playSFX('assets/audio/sound-effect/exit_button_sound.wav');
        showAnimatedDialog(context: context, child: ExitButtonAlert());
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A1818), Color(0xFF2A0C0C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.logout_rounded,
            color: const Color(0xFFFCA5A5),
            size: buttonSize * 0.55,
          ),
        ),
      ),
    );
  }
}