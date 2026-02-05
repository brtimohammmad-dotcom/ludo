import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

const Map<int, int> playerStartIndex = {
  1: 0, // قرمز
  2: 13, // آبی
  3: 26, // زرد
  4: 39, // سبز
};

int globalPlayerIndex({required int pathIndex, required int playerIndex}) {
  return (playerStartIndex[playerIndex]! + pathIndex) % 57;
}

void kill({
  required Token liveToken,
  required List<Token> tokens,
  required TokensController controller,
  required DiceController diceController,
}) {
  final List<Token> newTokenLists = tokens.map((token) {
    if(token.pathIndex<=51){
      final globalLiveTokenPath = globalPlayerIndex(
        pathIndex: liveToken.pathIndex,
        playerIndex: liveToken.player,
      )+diceController.diceValue.value.random;
      final globalTokenPath = globalPlayerIndex(
        pathIndex: token.pathIndex,
        playerIndex: token.player,
      );
      if (globalTokenPath == globalLiveTokenPath) {
        return token.copyWith(newPathIndex: -1);
      }else{
        return token;
      }
    }
     else {
      return token;
    }
  }).toList();
  controller.tokenNotifier.value = newTokenLists;
}
