import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';

void playerActivation({
  required DiceController diceController,
  required TokensController tokensController,
  required PlayerActivationState playerActivationState,
}) {
  final diceValue = diceController.diceValue.value;
  final canTokenActive = tokensController.tokenNotifier.value.any(
    (token) =>
        token.player == diceValue.currentPlayerActiveNumber &&
        (!token.isInHome || diceValue.random == 6),
  );
  if (canTokenActive) {
    playerActivationState.activePlayer();
  }
}
