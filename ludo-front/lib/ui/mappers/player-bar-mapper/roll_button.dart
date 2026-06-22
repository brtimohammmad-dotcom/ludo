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
    // 🎯 گوش دادن هوشمند به وضعیت نوبت تاس ریختن کاربر
    final myTurnToRoll = ref.watch(
      gameControllerProvider.select((state) => state?.isMyTurnToRoll ?? false),
    );

    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: boardSize * 0.01),
      child: Container(
        decoration: BoxDecoration(
          gradient: myTurnToRoll
              ? LinearGradient(
            colors: [
              Colors.lightGreenAccent,
              Colors.lightGreenAccent.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(colors: [Colors.white30, Colors.white38]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: boardSize * 0.02),
            backgroundColor: Colors.transparent,
            foregroundColor: myTurnToRoll ? Colors.white : Colors.white54,
            elevation: myTurnToRoll ? 4 : 0,
            shadowColor: Colors.green.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: myTurnToRoll ? () => gameControllerNotifier.rollDice() : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: boardSize * 0.03,
              vertical: boardSize * 0.01,
            ),
            child: Text('roll', style: TextStyle(fontSize: boardSize * 0.03)),
          ),
        ),
      ),
    );
  }
}