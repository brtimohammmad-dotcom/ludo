import 'package:flutter/material.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';
import 'package:ludo/ui/elements/dice/on-tap-dice/on_tap_dice.dart';

class DiceWidget extends StatelessWidget {
  final DiceController diceController;
  final double cellSize;
  final GameLogic gameLogic;
  final PlayerActivationState playerActivationState;
  final TokensController tokensController;
  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceController,
    required this.gameLogic,
    required this.playerActivationState,
    required this.tokensController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: diceController.diceValue,
      builder: (context, diceControllerValue, _) {
        final activePlayerIndex =
            diceControllerValue.currentPlayerActiveNumber - 1;
        return AnimatedPositioned(
          curve: Curves.easeOutCirc,
          duration: const Duration(milliseconds: 500),
          left: dicePath[activePlayerIndex].dy * cellSize,
          top: dicePath[activePlayerIndex].dx * cellSize,
          child: GestureDetector(
            onTap: onTapDice(
              diceInTurnNextPlayer: false,
              diceController: diceController,
              playerActivationState: playerActivationState,
              tokensController: tokensController,
              gameLogic: gameLogic,
            ),
            child: Container(
              color: Colors.white,
              width: cellSize * 2,
              height: cellSize * 2,
              child: Center(
                child: Text(
                  ('${diceControllerValue.random}'),
                  style: const TextStyle(color: Colors.black, fontSize: 50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
