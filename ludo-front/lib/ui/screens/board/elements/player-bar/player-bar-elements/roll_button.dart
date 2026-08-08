import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

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

    return RepaintBoundary(
      child: GestureDetector(
        onTap: myTurnToRoll ? () => gameControllerNotifier.rollDice() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: boardSize * 0.05,
            vertical: boardSize * 0.012,
          ),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            // 🪵 گرادیانت طلایی/سبز زیتونی لوکس هنگام فعال بودن و چوب تیره هنگام غیرفعال بودن
            gradient: LinearGradient(
              colors: myTurnToRoll
                  ? const [Color(0xFF2E7D32), Color(0xFF1B5E20)]
                  : const [Color(0xFF2A160C), Color(0xFF1E0E07)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: myTurnToRoll
                  ? const Color(0xFFFFD700)
                  : const Color(0xFF8B5A2B).withValues(alpha: 0.4),
              width: myTurnToRoll ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (myTurnToRoll)
                const BoxShadow(
                  color: Color(0x66FFD700),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Text(
            context.tr('ROLL'),
            style: TextStyle(
              color: myTurnToRoll
                  ? const Color(0xFFFFF8DC)
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: boardSize * 0.024,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: myTurnToRoll
                  ? const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}