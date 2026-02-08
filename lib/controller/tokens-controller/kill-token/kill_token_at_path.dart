import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-kill-token/can_kill_token.dart';

Token killTokenAtPath({
  required Token liveToken,
  required DiceController diceController,
  required int maxTrackPathIndex,
  required Token targetToken,
  required int globalTokenPath
}) {
  final targetPathIndex =
      liveToken.pathIndex + diceController.diceValue.value.value;
  if (targetPathIndex > maxTrackPathIndex) {
    return targetToken;
  }
  final globalLiveTokenPath = globalPlayerIndex(
    pathIndex: targetPathIndex,
    playerIndex: liveToken.player,
  );
  final isOnMainTrack =
      targetToken.pathIndex >= 0 && targetToken.pathIndex <= maxTrackPathIndex;
  if (!isOnMainTrack) {
    return targetToken;
  }
  if (canKillToken(
    liveToken: liveToken,
    globalLiveTokenPath: globalLiveTokenPath,
    targetToken: targetToken,
    globalTokenPath: globalTokenPath,
  )) {
    return targetToken.copyWith(newPathIndex: -1);
  }
  return targetToken;
}
