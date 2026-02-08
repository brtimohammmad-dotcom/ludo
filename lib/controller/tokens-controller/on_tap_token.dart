import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/move-token/move_token_function.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-move-token/can_move_oken.dart';

GestureTapCallback? onTapToken({
  required Token token,
  required DiceController diceController,
  required TokensController controller,
  required GameController gameController,
}) {
  return () {
    final tokens = controller.tokenNotifier.value;
    final liveToken = tokens.firstWhere(
      (item) => item.id == token.id,
      orElse: () => token,
    );

    if (!canMoveToken(
      liveToken: liveToken,
      tokens: tokens,
      diceController: diceController,
      gameController: gameController,
      controller: controller,
    )) {
      return;
    }
    moveTokenSafely(
      liveToken: liveToken,
      tokenNotifier: controller,
      token: liveToken,
      diceController: diceController,
      gameController: gameController,
    );
  };
}
