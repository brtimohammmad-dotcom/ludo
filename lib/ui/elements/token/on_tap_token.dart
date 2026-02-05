import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/move_token_function.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/elements/change_game_turn.dart';

GestureTapCallback? onTapToken({
  required Token token,
  required GameLogic gameLogic,
  required DiceController diceController,
  required TokensController controller,
}) {
  return () {
    debugPrint('active player ${gameLogic.currentPlayerActiveNumber}');
    debugPrint('player: ${token.player}');
    debugPrint('${token.isActive}\t${token.id}');
    if (gameLogic.currentPlayerActiveNumber == token.player&&token.isActive) {
      if ((diceController.diceValue.value.diceRolled ||
          diceController.diceValue.value.extraMove)) {
        moveTokenSafely(
          tokenNotifier: controller,
          token: token,
          diceController: diceController,
          gameLogic: gameLogic,
        );

        if (diceController.diceValue.value.extraMove &&
            diceController.diceValue.value.diceRolled) {
          diceController.diceValue.value.extraMove = false;
          diceController.diceValue.value.diceRolled = false;
        } else if (!diceController.diceValue.value.extraMove &&
            diceController.diceValue.value.diceRolled) {
          changeGameTurn(gameLogic: gameLogic, diceController: diceController);
        }
      }
    }
  };
}
