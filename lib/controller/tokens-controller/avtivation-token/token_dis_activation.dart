import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/model/token.dart';

void tokenDisActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameController gameController,
}) {
  final newTokenList = List<Token>.from(tokensController.tokenNotifier.value);
  final updatedTokenList = newTokenList.map((token) {

    return token.copyWith(newIsActive: false);
  }).toList();
  tokensController.tokenNotifier.value = updatedTokenList;
}
