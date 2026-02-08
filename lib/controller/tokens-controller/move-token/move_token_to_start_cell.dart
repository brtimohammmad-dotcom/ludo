import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/kill/kill.dart';

Future<void> moveTokenToStartCell({
  required int tokenId,
  required TokensController tokenNotifier,
  required DiceController diceController,
  required Token liveToken,
}) async {
  if (!tokenNotifier.isMoving && diceController.diceValue.value.value == 6) {
    tokenNotifier.isMoving = true;
    List<Token> newTokenNotifier = List<Token>.from(
      tokenNotifier.tokenNotifier.value,
    );

    newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
      newPathIndex: 0,
    );
    tokenNotifier.tokenNotifier.value = newTokenNotifier;
    await Future.delayed(const Duration(milliseconds: 300));
    kill(
      liveToken: liveToken,
      controller: tokenNotifier,
      diceController: diceController,
    );
    tokenNotifier.isMoving = false;
  }
  diceController.diceRolled = false;
}
