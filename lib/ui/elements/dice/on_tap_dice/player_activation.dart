import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';

void playerActivation({
  required TokensController tokensController,
  required PlayerActivationState playerActivationState,
}) {
  final canTokenActive = tokensController.tokenNotifier.value.any(
    (token) =>
        token.isActive
  );
  if (canTokenActive) {
    playerActivationState.activePlayer();
  }
}
