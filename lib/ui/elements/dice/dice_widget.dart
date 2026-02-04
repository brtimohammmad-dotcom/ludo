import 'package:flutter/material.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/token_activation_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';

class DiceWidget extends StatelessWidget {
  final DiceController diceController;
  final double cellSize;
  final GameLogic gameLogic;
  final TokenActivationController tokenActivationController;
  final TokensController tokensController;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceController,
    required this.gameLogic,
    required this.tokenActivationController,
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
            onTap: () async {
              if (!diceControllerValue.diceRolled) {
                tokenActivationController.disActiveToken();
                diceController.rollDice();

                final diceValue = diceController.diceValue.value;
                for (final token in tokensController.tokenNotifier.value) {
                  if (diceValue.currentPlayerActiveNumber != token.player) {
                    continue;
                  }

                  final canActivate =
                      token.isInHome ? diceValue.random == 6 : true;
                  if (canActivate) {
                    tokenActivationController.activeToken();
                    break;
                  }
                }

                if (!tokenActivationController.isActiveNotifier.value) {
                  gameLogic.currentPlayerChanger();
                  diceController.diceValue.value = diceController
                      .diceValue
                      .value
                      .changeCurrentPlayerActiveNumber(
                        gameLogic.currentPlayerActiveNumber,
                      );
                  diceController.diceValue.value.diceRolled = false;
                }
              }
              await Future.delayed(const Duration(milliseconds: 500));
            },
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
