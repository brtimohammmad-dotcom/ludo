import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/audio_service.dart';

class TargetCounterWidget extends ConsumerWidget {
  const TargetCounterWidget({
    super.key,
    required this.playerColor,
    required this.positionLeft,
    required this.positionTop,
  });

  final PlayerColor playerColor;
  final double positionLeft;
  final double positionTop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    // گوش دادن اختصاصی فقط به تعداد مهره‌های نهایی همین رنگ
    final targetCount = ref.watch(
      gameControllerProvider.select(
        (state) => state.getTargetTokensCountByColor(playerColor),
      ),
    );

    // بهینه‌سازی: پخش افکت صدا فقط زمانی که یک مهره تازه به خانه رسیده‌ است،
    // نه در هر rebuild (قبلاً داخل build بود و باعث پخش مکرر صدا و تخصیص Howl می‌شد).
    ref.listen<int>(
      gameControllerProvider.select(
        (state) => state.getTargetTokensCountByColor(playerColor),
      ),
      (previous, next) {
        final gameStage = ref.read(
          gameControllerProvider.select((s) => s?.gameStage),
        );
        if (gameStage != GameStage.boardStage) {
          return;
        }
        if ((previous ?? 0) < next) {
          ref
              .read(audioServiceProvider.notifier)
              .playSFX("assets/audio/sound-effect/target_token.wav");
        }
      },
    );

    // انیمیشن بر اساس تعداد مهره‌ها (اگر صفر باشد غایب است)
    final double scale = targetCount > 0 ? 1.0 : 0.0;

    return Positioned(
      left: positionLeft,
      top: positionTop,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceOut, // افکت پاپ‌آپ جذاب هنگام پدیدار شدن
        child: Container(
          padding: EdgeInsets.all(boardSize * 0.01),
          decoration: BoxDecoration(
            color: _getFlutterColor(playerColor),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: boardSize * 0.0033),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$targetCount',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // متد مپ کردن رنگ دامنه به رنگ ویژوال فلاتر
  Color _getFlutterColor(PlayerColor color) {
    switch (color) {
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.yellow:
        return Colors.amber; // یا Colors.yellow
      case PlayerColor.blue:
        return Colors.blue;
    }
  }
}
