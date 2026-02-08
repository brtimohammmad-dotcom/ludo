import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill.dart';

Future<void> moveTokenStepByStep({
  required Token liveToken,
  required TokensController tokenNotifier,
  required DiceController diceController,
  required GameController gameController,
}) async {
  int steps = diceController.diceValue.value.value;
  if (!tokenNotifier.isMoving) {
    List<Token> current = List.from(tokenNotifier.tokenNotifier.value);

    int index = liveToken.id - 1;
    Token token = current[index];

    for (int i = 0; i < steps; i++) {
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
  }
}