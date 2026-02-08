import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/move-token/move_token_to_start_cell.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/kill/kill.dart';

Future<void> moveTokenSafely({
  required Token liveToken,
  required DiceController diceController,
  required TokensController tokenNotifier,
  required Token token,
  required GameController gameController,
}) async {
  bool isInHome = token.isInHome;
  int tokenId = token.id;
  if (tokenNotifier.isMoving) {
    return;
  }
  if (isInHome) {
    await moveTokenToStartCell(tokenId: tokenId,
        tokenNotifier: tokenNotifier,
        diceController: diceController,
        liveToken: liveToken);
  } else {
    await moveTokenStepByStep(
      liveToken: liveToken,
      tokenId: tokenId,
      steps: diceController.diceValue.value.value,
      tokenNotifier: tokenNotifier,
      diceController: diceController,
      gameController: gameController,
    );
  }
  DiceTapLock.unlock();
}


Future<void> moveTokenStepByStep({
  required Token liveToken,
  required int tokenId,
  required int steps,
  required TokensController tokenNotifier,
  required DiceController diceController,
  required GameController gameController,
}) async {
  if (!tokenNotifier.isMoving) {
    List<Token> current = List.from(tokenNotifier.tokenNotifier.value);

    int index = tokenId - 1;
    Token token = current[index];

    for (int i = 0; i < steps; i++) {
      if (token.pathIndex >= 57) {
        break;
      }
      tokenNotifier.isMoving = true;
      token = token.copyWith(newPathIndex: token.pathIndex + 1);
      current[index] = token;
      tokenNotifier.tokenNotifier.value = List.from(current);

      await Future.delayed(const Duration(milliseconds: 300));
    }
    kill(
      liveToken: liveToken,
      controller: tokenNotifier,
      diceController: diceController,
    );
    tokenNotifier.isMoving = false;
    if (diceController.extraMove && diceController.diceRolled) {
      diceController.extraMove = false;
      diceController.diceRolled = false;
    } else if (!diceController.extraMove && diceController.diceRolled) {
      gameController.nextPlayer();
      diceController.resetForNextTurn();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
