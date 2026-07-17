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
        ref.read(audioServiceProvider).playSFX('assets/audio/sound-effect/exit_button_sound.wav');
        showAnimatedDialog(context: context, child: ExitButtonAlert());
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: const Color(0x26FF3B30), // ۱۵٪ شفافیت قرمز ثابت
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x88FF3B30), width: 1.0),
        ),
        child: Center(
          child: Icon(
            Icons.logout_rounded,
            color: const Color(0xFFFF8A80),
            size: buttonSize * 0.55,
          ),
        ),
      ),
    );
  }
}