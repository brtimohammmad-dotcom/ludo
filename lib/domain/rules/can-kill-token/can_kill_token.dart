import 'package:ludo/domain/model/token.dart';

bool canKillToken({
  required Token liveToken,
  required int globalLiveTokenPath,
  required Token targetToken,
  required int globalTokenPath,
}) {
  final isOpponent = targetToken.player != liveToken.player;
  if (!isOpponent || targetToken.isInHome) {
    return false;
  }
  return globalTokenPath == globalLiveTokenPath;
}
