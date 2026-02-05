import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/game/game_logic.dart';

void updateTokenActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameLogic gameLogic,
}) {
  final tokens =tokensController.tokenNotifier.value;
  tokensController.tokenNotifier.value = tokens
      .map((token) {
    final sameTokenExist = tokens.any(
            (other) {
              return other.player == token.player &&
              other.pathIndex == (token.pathIndex + dice.random) &&
              !token.isInHome;
        }

    );

    final canActivate =
        token.player == gameLogic.currentPlayerActiveNumber &&
            (!token.isInHome || dice.random == 6) &&
            !sameTokenExist;

    return token.copyWith(newIsActive: canActivate);
  })
      .toList();
}
