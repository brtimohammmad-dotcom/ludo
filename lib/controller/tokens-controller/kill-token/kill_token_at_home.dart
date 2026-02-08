import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/tokens-controller/kill-token/kill.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-kill-token/can_kill_token.dart';

Token killTokenAtHome({
  required Token liveToken,
  required DiceController diceController,
  required Token targetToken,
  required int globalTokenPath,
}) {
  final globalLiveTokenPath = globalPlayerIndex(
    pathIndex: 0,
    playerIndex: liveToken.player,
  );
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
