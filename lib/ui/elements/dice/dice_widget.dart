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
        return AnimatedPositioned(
          curve: Curves.easeOutCirc,
          duration: Duration(milliseconds: 500),
          left:
              dicePath[diceControllerValue.currentPlayerActiveNumber - 1].dy *
              cellSize,
          top:
              dicePath[diceControllerValue.currentPlayerActiveNumber - 1].dx *
              cellSize,
          child: GestureDetector(
            onTap: () async {
              if (!diceControllerValue.diceRolled) {
                tokenActivationController.disActiveToken();
                diceController.rollDice();
                for (Token token in tokensController.tokenNotifier.value) {
                  if (diceController
                          .diceValue
                          .value
                          .currentPlayerActiveNumber ==
                      token.player) {
                    if (token.isInHome &&
                        diceController.diceValue.value.random == 6) {
                      tokenActivationController.activeToken();

                      break;
                    }
                    if (!token.isInHome) {
                      tokenActivationController.activeToken();
                      break;
                    }
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
              await Future.delayed(Duration(milliseconds: 500));
            },
            child: Container(
              color: Colors.white,
              width: cellSize * 2,
              height: cellSize * 2,
              child: Center(
                child: Text(
                  ('${diceControllerValue.random}'),
                  style: TextStyle(color: Colors.black, fontSize: 50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
