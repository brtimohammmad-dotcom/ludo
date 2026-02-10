import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/avtivation-token/token_dis_activation.dart';
import 'package:ludo/controller/tokens-controller/kill-token/find_kill_tokens.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill_tokens.dart';
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
  return () async {
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
    tokenDisActivation(
      tokensController: controller,
      dice: diceController.diceValue.value,
      gameController: gameController,
    );
    await moveTokenSafely(
      liveToken: liveToken,
      tokenNotifier: controller,
      diceController: diceController,
      gameController: gameController,
    );

    final killedTarget = findKillTarget(
      liveToken: liveToken,
      controller: controller,
      diceController: diceController,
    );
    if (killedTarget != null) {
      killTokens(controller, killedTarget);
    }
    if (diceController.extraMove) {
      diceController.extraMove = false;
      DiceTapLock.unlock();
      return;
    }
    gameController.nextPlayer();
    diceController.resetForNextTurn();
  };
}
