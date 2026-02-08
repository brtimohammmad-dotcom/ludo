import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/token_activation.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/rules/can-active-player/can_active_player.dart';

GestureTapCallback? onTapDice({
  required DiceController diceController,
  required TokensController tokensController,
  required GameController gameController,
}) {
  return () async {
    if (!DiceTapLock.isLocked) {
      DiceTapLock.tryLock();
      diceController.rollDice();
      updateTokenActivation(
        tokensController: tokensController,
        dice: diceController.diceValue.value,
        gameController: gameController,
      );
      if (canActivePlayer(
        diceController: diceController,
        tokensController: tokensController,
      )) {
        return;
      }
      if(diceController.extraMove){
        DiceTapLock.unlock();
        return;
      }
      await Future.delayed(Duration(seconds: 1));
      gameController.nextPlayer();
      diceController.resetForNextTurn();
    }
  };
}
