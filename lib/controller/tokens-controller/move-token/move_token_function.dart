import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/move-token/move_token_step_by_step.dart';
import 'package:ludo/controller/tokens-controller/move-token/move_token_to_start_cell.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

Future<void> moveTokenSafely({
  required Token liveToken,
  required DiceController diceController,
  required TokensController tokenNotifier,
  required GameController gameController,
}) async {
  bool isInHome = liveToken.isInHome;
  if (tokenNotifier.isMoving) {
    return;
  }
  if (isInHome) {
    await moveTokenToStartCell(
      tokenNotifier: tokenNotifier,
      diceController: diceController,
      liveToken: liveToken,
    );
  } else {
    await moveTokenStepByStep(
      liveToken: liveToken,
      tokenNotifier: tokenNotifier,
      diceController: diceController,
      gameController: gameController,
    );
  }
}


