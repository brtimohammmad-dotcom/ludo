import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/elements/change_game_turn.dart';
import 'package:ludo/ui/elements/dice/on_tap_dice/player_activation.dart';
import 'package:ludo/ui/elements/dice/on_tap_dice/token_activation.dart';

GestureTapCallback? onTapDice({
  required DiceController diceController,
  required PlayerActivationState playerActivationState,
  required TokensController tokensController,
  required GameLogic gameLogic,
}) {
  return () async {
    if (!diceController.diceValue.value.diceRolled) {

      playerActivationState.disActivePlayer();
      diceController.rollDice();
      playerActivation(
        diceController: diceController,
        tokensController: tokensController,
        playerActivationState: playerActivationState,
      );
      if (!playerActivationState.isActiveState) {
        changeGameTurn(gameLogic: gameLogic, diceController: diceController);
      } else {
        updateTokenActivation(
          tokensController: tokensController,
          dice: diceController.diceValue.value,
          gameLogic: gameLogic,
        );
      }
    }
    await Future.delayed(const Duration(milliseconds: 500));
  };
}
