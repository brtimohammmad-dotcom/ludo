import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill.dart';

Future<void> moveTokenToStartCell({
  required TokensController tokenNotifier,
  required DiceController diceController,
  required Token liveToken,
}) async {
    tokenNotifier.isMoving = true;
    List<Token> newTokenNotifier = List<Token>.from(
      tokenNotifier.tokenNotifier.value,
    );

    newTokenNotifier[liveToken.id - 1] = newTokenNotifier[liveToken.id - 1].copyWith(
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
