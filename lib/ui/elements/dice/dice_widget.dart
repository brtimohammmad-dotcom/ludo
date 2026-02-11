import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';

class DiceWidget extends StatelessWidget {
  final DiceController diceController;
  final double cellSize;
  final GameController gameController;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceController,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: gameController.currentPlayer,
      builder: (context, currentPlayer, _) {
        return ValueListenableBuilder(
          valueListenable: diceController.diceValue,
          builder: (context, diceControllerValue, _) {
            final activePlayerIndex = currentPlayer - 1;
            return ValueListenableBuilder(
              valueListenable: DiceTapLock.locked,
              builder: (context, locked, _) {
                return AnimatedPositioned(
                  curve: Curves.easeOutCirc,
                  duration: const Duration(milliseconds: 500),
                  left:
                      dicePath[activePlayerIndex].dy * cellSize +
                      (cellSize / 4),
                  top:
                      dicePath[activePlayerIndex].dx * cellSize +
                      (cellSize / 4),
                  child: GestureDetector(
                    onTap: () => gameController.onTapDice(),
                    child: AnimatedContainer(
                      padding: EdgeInsets.all(locked ? 10 : 7),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      width: cellSize * (1.5),
                      height: cellSize * (1.5),
                      decoration: BoxDecoration(
                        boxShadow: locked
                            ? [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(-4, 6),
                                  spreadRadius: -8,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                      child: Image.asset(
                        'assets/images/${diceControllerValue.value}.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
