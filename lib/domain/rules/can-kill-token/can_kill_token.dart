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

bool canKillToken({
  required Token liveToken,
  required int globalLiveTokenPath,
  required Token targetToken,
  required int globalTokenPath,
  required DiceController diceController,
}) {
  final isOpponent = targetToken.player != liveToken.player;
  if (!isOpponent || targetToken.isInHome) {
    return false;
  }
  return globalTokenPath == globalLiveTokenPath;
}
