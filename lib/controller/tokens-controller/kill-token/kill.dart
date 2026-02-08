import 'package:ludo/controller/dice-controller/dice_controller.dart';
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
  if (liveToken.isInHome) {
    final globalLiveTokenPath = globalPlayerIndex(
      pathIndex: 0,
      playerIndex: liveToken.player,
    );
    final List<Token> newTokenList = controller.tokenNotifier.value.map((
      targetToken,
    ) {
      final isOpponent = targetToken.player != liveToken.player;
      if (!isOpponent || targetToken.isInHome) {
        return targetToken;
      }
      final globalTokenPath = globalPlayerIndex(
        pathIndex: targetToken.pathIndex,
        playerIndex: targetToken.player,
      );
      if (globalTokenPath == globalLiveTokenPath) {
        return targetToken.copyWith(newPathIndex:-1);
      }
      return targetToken;
    }).toList();
    controller.tokenNotifier.value = newTokenList;
  } else {
    final targetPathIndex =
        liveToken.pathIndex + diceController.diceValue.value.value;
    if (targetPathIndex > _maxTrackPathIndex) {
      return;
    }
    final globalLiveTokenPath = globalPlayerIndex(
      pathIndex: targetPathIndex,
      playerIndex: liveToken.player,
    );
    final List<Token> newTokenList = controller.tokenNotifier.value.map((
      targetToken,
    ) {
      final isOpponent = targetToken.player != liveToken.player;
      final isOnMainTrack =
          targetToken.pathIndex >= 0 && targetToken.pathIndex <= _maxTrackPathIndex;

      if (!isOpponent || !isOnMainTrack) {
        return targetToken;
      }

      final globalTokenPath = globalPlayerIndex(
        pathIndex: targetToken.pathIndex,
        playerIndex: targetToken.player,
      );

      if (globalTokenPath == globalLiveTokenPath) {
        return targetToken.copyWith(newPathIndex: -1);
      }

      return targetToken;
    }).toList();
    controller.tokenNotifier.value = newTokenList;
  }
}
