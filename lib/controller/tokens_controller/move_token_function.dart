import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/kill/kill.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/elements/change_game_turn.dart';

Future<void> moveTokenSafely({
  required Token liveToken,
  required DiceController diceController,
  required TokensController tokenNotifier,
  required Token token,
  required GameLogic gameLogic,
}) async {
  bool isInHome = token.isInHome;
  int tokenId = token.id;
  if (!tokenNotifier.isMoving) {
    if (isInHome) {
      _moveTokenToStartCell(tokenId, tokenNotifier, diceController, gameLogic);
    } else {
      await _moveTokenStepByStep(
        liveToken: liveToken,
        tokenId: tokenId,
        steps: diceController.diceValue.value.random,
        tokenNotifier: tokenNotifier,
        diceController: diceController,
        gameLogic: gameLogic,
      );
    }
  }
}

Future<void> _moveTokenToStartCell(
  int tokenId,
  TokensController tokenNotifier,
  DiceController diceController,
  GameLogic gameLogic,
) async {
  if (!tokenNotifier.isMoving && diceController.diceValue.value.random == 6) {
    tokenNotifier.isMoving = true;
    List<Token> newTokenNotifier = List<Token>.from(
      tokenNotifier.tokenNotifier.value,
    );
    newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
      newPathIndex: 0,
    );
    tokenNotifier.tokenNotifier.value = newTokenNotifier;
    await Future.delayed(const Duration(milliseconds: 300));
    tokenNotifier.isMoving = false;
  }
  diceController.diceValue.value.diceRolled = false;
}

Future<void> _moveTokenStepByStep({
  required Token liveToken,
  required int tokenId,
  required int steps,
  required TokensController tokenNotifier,
  required DiceController diceController,
  required GameLogic gameLogic,
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
