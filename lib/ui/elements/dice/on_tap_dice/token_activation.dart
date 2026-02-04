// TokensController
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/game/game_logic.dart';

void updateTokenActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameLogic gameLogic,
}) {
  tokensController.tokenNotifier.value = tokensController.tokenNotifier.value.map((token) {
    final canActivate =
        token.player == gameLogic.currentPlayerActiveNumber &&
            (!token.isInHome || dice.random == 6);

    return token.copyWith(newIsActive: canActivate);
  }).toList();
}
