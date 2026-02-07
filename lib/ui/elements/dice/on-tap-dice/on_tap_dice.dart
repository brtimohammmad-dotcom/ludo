import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/elements/change_game_turn.dart';
import 'package:ludo/ui/elements/dice/on-tap-dice/player_activation.dart';
import 'package:ludo/controller/tokens_controller/token_activation.dart';

GestureTapCallback? onTapDice({
  required DiceController diceController,
  required PlayerActivationState playerActivationState,
  required TokensController tokensController,
  required GameLogic gameLogic,
  required bool diceInTurnNextPlayer,
}) {
  return () async {
    if (!diceController.diceValue.value.diceRolled &&
        !diceInTurnNextPlayer &&
        playerActivationState.isActiveState) {
      playerActivationState.disActivePlayer();
      diceController.rollDice();
      updateTokenActivation(
        tokensController: tokensController,
        dice: diceController.diceValue.value,
        gameLogic: gameLogic,
      );
      playerActivation(
        diceController: diceController,
        tokensController: tokensController,
        playerActivationState: playerActivationState,
      );
      if (!playerActivationState.isActiveState && !diceInTurnNextPlayer) {
        diceInTurnNextPlayer = true;
        await Future.delayed(Duration(seconds: 1));
        changeGameTurn(gameLogic: gameLogic, diceController: diceController);
        await Future.delayed(Duration(milliseconds: 500));
        playerActivationState.activePlayer();

        diceInTurnNextPlayer = false;
      }
    }
  };
}
