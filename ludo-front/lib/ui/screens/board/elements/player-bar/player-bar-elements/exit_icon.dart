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
            .read(audioServiceProvider)
            .playSFX('assets/audio/sound-effect/exit_button_sound.wav');
        showAnimatedDialog(context: context, child: ExitButtonAlert());
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          // 🌌 شیشه‌ای تیره با تم بنفش/صورتیِ نئونی ملایم مخصوص دکمه‌های خطر/خروج
          color: const Color(0x33FF3B30),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xAAFF3B30), // مرز نئونی قرمز
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33FF3B30),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.logout_rounded,
            color: const Color(0xFFFF8A80), // رنگ آیکون روشن و هماهنگ
            size: buttonSize * 0.55,
          ),
        ),
      ),
    );
  }
}