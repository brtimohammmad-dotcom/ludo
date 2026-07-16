import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class RollButton extends ConsumerWidget {
  const RollButton({
    super.key,
    required this.boardSize,
  });

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTurnToRoll = ref.watch(
      gameControllerProvider.select((state) => state?.isMyTurnToRoll ?? false),
    );

    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);
    final borderRadius = BorderRadius.circular(boardSize * 0.015);

    // 🟢 سبز نئونی گداخته و درخشان برای حالت فعال
    final activeGradient = LinearGradient(
      colors: [
        const Color(0xFF00FF87), // سبز فسفری نئون
        const Color(0xFF60EFFF), // فیروزه‌ای نئون
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // ⚪ حالت غیر فعال شیشه‌ای مات و شیک
    final inactiveGradient = const LinearGradient(
      colors: [Color(0x1AFFFFFF), Color(0x0DFFFFFF)],
    );

    return RepaintBoundary(
      child: GestureDetector(
        onTap: myTurnToRoll ? () => gameControllerNotifier.rollDice() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: boardSize * 0.05,
            vertical: boardSize * 0.012,
          ),
          decoration: BoxDecoration(
            gradient: myTurnToRoll ? activeGradient : inactiveGradient,
            borderRadius: borderRadius,
            boxShadow: myTurnToRoll
                ? [
              BoxShadow(
                color: const Color(0x5500FF87),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ]
                : null,
            border: Border.all(
              color: myTurnToRoll ? const Color(0xFF00FF87) : Colors.white12,
              width: 1.2,
            ),
          ),
          child: Text(
            'ROLL',
            style: TextStyle(
              color: myTurnToRoll ? const Color(0xFF0A0A12) : Colors.white38, // متن تیره روی دکمه روشن برای کنتراست فوق‌العاده
              fontSize: boardSize * 0.024,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}