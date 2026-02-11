import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/player_rules.dart';
import 'package:ludo/domain/rules/token_rules.dart';

class GameController {
  final ValueNotifier<int> currentPlayer = ValueNotifier(1);
  final TokensController tokensController;
  final DiceController diceController;
  late final PlayerRules playerRules;

  GameController({
    required this.tokensController,
    required this.diceController,
  }) {
    playerRules = PlayerRules();
  }

  void nextPlayer() {
    currentPlayer.value = currentPlayer.value % 4 + 1;
  }

  Future<void> onTapToken({required Token token}) async {
    if (!DiceTapLock.locked.value) {
      return;
    }
    final tokens = tokensController.tokenNotifier.value;
    final liveToken = tokens.firstWhere(
      (item) => item.id == token.id,
      orElse: () => token,
    );

    if (!liveToken.isActive || liveToken.player != currentPlayer.value) {
      return;
    }
    TokenRules tokenRules = TokenRules(
      currentPlayer: currentPlayer.value,
      tokens: tokens,
      diceController: diceController,
    );

    tokensController.tokenDisActivation();
    await tokensController.moveTokenSafely(
      liveToken: liveToken,
      diceController: diceController,
    );

    final killedTarget = tokenRules.findKillTarget(liveToken: liveToken);
    if (killedTarget != null) {
      tokensController.killToken(targetToken: killedTarget);
    }
    if (diceController.extraMove) {
      diceController.extraMove = false;
      DiceTapLock.unlock();
      return;
    }
    nextPlayer();
    diceController.resetForNextTurn();
  }

  Future<void> onTapDice() async {
    if (DiceTapLock.locked.value) {
      return;
    }
    DiceTapLock.tryLock();
    diceController.rollDice();
    tokensController.updateTokenActivation(
      currentPlayer: currentPlayer.value,
      diceController: diceController,
    );
    if (playerRules.canActivePlayer(tokensController: tokensController)) {
      return;
    }
    if (diceController.extraMove) {
      DiceTapLock.unlock();
      return;
    }
    await Future.delayed(Duration(seconds: 1));
    nextPlayer();
    diceController.resetForNextTurn();
  }
}
