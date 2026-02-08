import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';
import 'package:ludo/controller/dice-controller/on_tap_dice.dart';

class DiceWidget extends StatelessWidget {
  final DiceController diceController;
  final double cellSize;
  final TokensController tokensController;
  final GameController gameController;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceController,
    required this.tokensController,
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
            final activePlayerIndex =
               currentPlayer  - 1;
            return AnimatedPositioned(
              curve: Curves.easeOutCirc,
              duration: const Duration(milliseconds: 500),
              left: dicePath[activePlayerIndex].dy * cellSize,
              top: dicePath[activePlayerIndex].dx * cellSize,
              child: GestureDetector(
                onTap: onTapDice(
                  gameController: gameController,
                  diceController: diceController,
                  tokensController: tokensController,
                ),
                child: Container(
                  width: cellSize * 2,
                  height: cellSize * 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54.withAlpha(50),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/${diceController.diceValue.value.value}.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
