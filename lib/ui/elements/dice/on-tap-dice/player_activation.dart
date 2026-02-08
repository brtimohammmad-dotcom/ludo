import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';

void playerActivation({
  required TokensController tokensController,
  required PlayerActivationState playerActivationState,
  required DiceController diceController
}) {
  final canTokenActive = tokensController.tokenNotifier.value.any(
    (token) =>
        token.isActive
  );
  if (canTokenActive||diceController.extraMove) {
    playerActivationState.activePlayer();
  }
}
