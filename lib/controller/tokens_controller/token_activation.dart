import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/can-active-token/can_active_token.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/game/game_logic.dart';



void updateTokenActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameLogic gameLogic,
}) {
  final tokens = tokensController.tokenNotifier.value;
  tokensController.tokenNotifier.value = tokens.map((token) {
    final canActivate = canActivateToken(
      token: token,
      tokens: tokens,
      dice: dice,
      gameLogic: gameLogic,
    );

    return token.copyWith(newIsActive: canActivate);
  }).toList();
}
