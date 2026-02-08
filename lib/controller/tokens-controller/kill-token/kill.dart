import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill_token_at_home.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill_token_at_path.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

const Map<int, int> playerStartIndex = {
  1: 0, // قرمز
  2: 13, // آبی
  3: 26, // زرد
  4: 39, // سبز
};
const int _mainTrackLength = 52;
const int _maxTrackPathIndex = 51;

int globalPlayerIndex({required int pathIndex, required int playerIndex}) {
  return (playerStartIndex[playerIndex]! + pathIndex) % _mainTrackLength;
}

void kill({
  required Token liveToken,
  required TokensController controller,
  required DiceController diceController,
}) {
  final List<Token> newTokenList = controller.tokenNotifier.value.map((
      targetToken,) {
    final globalTokenPath = globalPlayerIndex(
      pathIndex: targetToken.pathIndex,
      playerIndex: targetToken.player,
    );
    if (liveToken.isInHome) {
      return killTokenAtHome(liveToken: liveToken,
          diceController: diceController,
          targetToken: targetToken,
          globalTokenPath: globalTokenPath);
    } else {
      return killTokenAtPath(liveToken: liveToken,
          diceController: diceController,
          maxTrackPathIndex: _maxTrackPathIndex,
          targetToken: targetToken,
          globalTokenPath: globalTokenPath);
    }
  }).toList();
  controller.tokenNotifier.value = newTokenList;
}
