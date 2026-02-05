import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/move_token_function.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/can-active-token/can_active_token.dart';
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
    final tokens = controller.tokenNotifier.value;
    final liveToken = tokens.firstWhere(
      (item) => item.id == token.id,
      orElse: () => token,
    );
    final canTapToken = canActivateToken(
      token: liveToken,
      tokens: tokens,
      dice: diceController.diceValue.value,
      gameLogic: gameLogic,
    );

    if (gameLogic.currentPlayerActiveNumber == liveToken.player &&
        canTapToken) {
      if ((diceController.diceValue.value.diceRolled ||
          diceController.diceValue.value.extraMove)) {
        moveTokenSafely(
          tokenNotifier: controller,
          token: liveToken,
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
