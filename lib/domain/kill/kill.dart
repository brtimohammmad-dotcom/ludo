import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
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
  if (liveToken.pathIndex < 0) {
    return;
  }
  final targetPathIndex =
      liveToken.pathIndex + diceController.diceValue.value.random;
  if (targetPathIndex > _maxTrackPathIndex) {
    return;
  }
  final globalLiveTokenPath = globalPlayerIndex(
    pathIndex: targetPathIndex,
    playerIndex: liveToken.player,
  );
  final List<Token> newTokenLists = controller.tokenNotifier.value.map((token) {
    final isOpponent = token.player != liveToken.player;
    final isOnMainTrack =
        token.pathIndex >= 0 && token.pathIndex <= _maxTrackPathIndex;

    if (!isOpponent || !isOnMainTrack) {
      return token;
    }

    final globalTokenPath = globalPlayerIndex(
      pathIndex: token.pathIndex,
      playerIndex: token.player,
    );

    if (globalTokenPath == globalLiveTokenPath) {
      return token.copyWith(newPathIndex: -1);
    }

    return token;
  }).toList();
  controller.tokenNotifier.value = newTokenLists;
}
