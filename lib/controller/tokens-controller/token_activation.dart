import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/rules/can-active-token/can_active_token.dart';



void updateTokenActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameController gameController
}) {
  final tokens = tokensController.tokenNotifier.value;
  tokensController.tokenNotifier.value = tokens.map((token) {
    final canActivate = canActivateToken(
      token: token,
      tokens: tokens,
      dice: dice,
      gameController: gameController,
    );

    return token.copyWith(newIsActive: canActivate);
  }).toList();
}
