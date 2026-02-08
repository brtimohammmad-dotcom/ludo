import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';

bool canActivePlayer({
  required TokensController tokensController,
  required DiceController diceController
}) {
  final canTokenActive = tokensController.tokenNotifier.value.any(
    (token) =>
        token.isActive
  );
  return canTokenActive||diceController.extraMove;

}
