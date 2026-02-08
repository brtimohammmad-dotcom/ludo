import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-active-token/can_active_token.dart';

bool canMoveToken({
  required Token liveToken,
  required List<Token> tokens,
  required DiceController diceController,
  required GameController gameController,
  required TokensController controller
}) {
  final canTapToken = canActivateToken(
    token: liveToken,
    tokens: tokens,
    dice: diceController.diceValue.value,
    gameController: gameController,
  );
  return DiceTapLock.isLocked&&
      canTapToken &&
      !controller.isMoving;
}
