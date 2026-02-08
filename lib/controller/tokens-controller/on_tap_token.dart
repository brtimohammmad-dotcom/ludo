import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/move_token_function.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-active-token/can_active_token.dart';

GestureTapCallback? onTapToken({
  required Token token,
  required DiceController diceController,
  required TokensController controller,
  required GameController gameController
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
      gameController: gameController,
    );

    if (gameController.currentPlayer.value == liveToken.player &&
        canTapToken &&
        !controller.isMoving) {
      if ((diceController.diceRolled ||
          diceController.extraMove)) {
        moveTokenSafely(
          liveToken: liveToken,
          tokenNotifier: controller,
          token: liveToken,
          diceController: diceController,
          gameController: gameController
        );
      }
    }
  };
}
