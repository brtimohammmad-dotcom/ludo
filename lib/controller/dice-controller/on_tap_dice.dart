import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/token_activation.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/ui/elements/dice/on-tap-dice/player_activation.dart';

GestureTapCallback? onTapDice({
  required DiceController diceController,
  required PlayerActivationState playerActivationState,
  required TokensController tokensController,
  required GameController gameController,
}) {
  return () async {
    if (!diceController.diceRolled &&
        !DiceTapLock.isLocked &&
        playerActivationState.isActiveState) {
      playerActivationState.disActivePlayer();
      diceController.rollDice();
      updateTokenActivation(
        tokensController: tokensController,
        dice: diceController.diceValue.value,
        gameController: gameController,
      );
      playerActivation(
        diceController: diceController,
        tokensController: tokensController,
        playerActivationState: playerActivationState,
      );
      if (!playerActivationState.isActiveState) {
        DiceTapLock.tryLock();
        await Future.delayed(Duration(seconds: 1));
        gameController.nextPlayer();
        diceController.resetForNextTurn();
        await Future.delayed(Duration(milliseconds: 500));
        playerActivationState.activePlayer();

        DiceTapLock.unlock();
      }
    }
  };
}
