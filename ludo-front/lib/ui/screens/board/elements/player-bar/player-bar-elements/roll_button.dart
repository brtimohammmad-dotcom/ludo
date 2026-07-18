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

    return RepaintBoundary(
      child: GestureDetector(
        onTap: myTurnToRoll ? () => gameControllerNotifier.rollDice() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: EdgeInsets.symmetric(
            horizontal: boardSize * 0.05,
            vertical: boardSize * 0.012,
          ),
          decoration: BoxDecoration(
            color: myTurnToRoll ? const Color(0xFF22C55E) : const Color(0xFF334155), // سبز فلت یا خاکستری مات بدون گرادینت و سایه
            borderRadius: borderRadius,
            border: Border.all(
              color: myTurnToRoll ? const Color(0xFF4ADE80) : const Color(0xFF475569),
              width: 1.0,
            ),
          ),
          child: Text(
            'ROLL',
            style: TextStyle(
              color: myTurnToRoll ? Colors.white : Colors.white30,
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