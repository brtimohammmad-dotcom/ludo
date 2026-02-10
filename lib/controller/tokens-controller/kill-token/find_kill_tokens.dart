import 'package:ludo/controller/dice-controller/dice_controller.dart';

import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:collection/collection.dart';

const Map<int, int> playerStartIndex = {
  1: 0, // قرمز
  2: 9, // آبی
  3: 18, // زرد
  4: 27, // سبز
};
const int _mainTrackLength = 36;
const int _maxTrackPathIndex = 35;

int globalPlayerIndex({required int pathIndex, required int playerIndex}) {
  return (playerStartIndex[playerIndex]! + pathIndex) % _mainTrackLength;
}

Token? findKillTarget({
  required Token liveToken,
  required TokensController controller,
  required DiceController diceController,
}) {
  final tokens = controller.tokenNotifier.value;

  final targetPathIndex =
      liveToken.pathIndex + diceController.diceValue.value.value;

  if (targetPathIndex > _maxTrackPathIndex) {
    return null;
  }

  final Token? killedToken = tokens.firstWhereOrNull((targetToken) {
    final isOnMainTrack =
        targetToken.pathIndex >= 0 &&
        targetToken.pathIndex <= _maxTrackPathIndex;
    final isOpponent = targetToken.player != liveToken.player;
    if (!isOnMainTrack || !isOpponent) {
     return false;
    }
    final int globalLiveTokenPath;
    final globalTokenPath = globalPlayerIndex(
      pathIndex: targetToken.pathIndex,
      playerIndex: targetToken.player,
    );
    if (liveToken.isInHome) {
      globalLiveTokenPath = globalPlayerIndex(
        pathIndex: 0,
        playerIndex: liveToken.player,
      );
    } else {
      globalLiveTokenPath = globalPlayerIndex(
        pathIndex: targetPathIndex,
        playerIndex: liveToken.player,
      );
    }
    if (globalTokenPath == globalLiveTokenPath) {
      return true;
    }
    return false;
  });
  return killedToken;
}
