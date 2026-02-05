import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/move_token_function.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/can-active-token/can_active_token.dart';
import 'package:ludo/domain/kill/kill.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';

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
        canTapToken &&
        !controller.isMoving) {
      if ((diceController.diceValue.value.diceRolled ||
          diceController.diceValue.value.extraMove)) {
        kill(
          liveToken: liveToken,
          tokens: tokens,
          controller: controller,
          diceController: diceController,
        );
        moveTokenSafely(
          tokenNotifier: controller,
          token: liveToken,
          diceController: diceController,
          gameLogic: gameLogic,
        );
      }
    }
  };
}
