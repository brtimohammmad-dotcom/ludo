import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

class TokenRules {
  static final Map<PlayerColor, int> _playerStartIndex = {
    PlayerColor.red: 0, // قرمز
    PlayerColor.blue: 9, // آبی
    PlayerColor.yellow: 18, // زرد
    PlayerColor.green: 27, // سبز
  };
  static final int _mainTrackLength = 36;

  static int _globalPlayerIndex({
    required int pathIndex,
    required PlayerColor playerColor,
  }) {
    return (_playerStartIndex[playerColor]! + pathIndex) % _mainTrackLength;
  }

  static bool canActiveToken(Token liveToken, GameState? gameState) {
    if (gameState!.serverState!.turnStatus != TurnStatus.waitingForMove) {
      return false;
    }
    final targetPathIndex =
        liveToken.pathIndex + gameState.serverState!.lastDiceValue.toInt();
    bool canNotActiveToken = false;
    gameState.serverState!.tokens.any((otherToken) {
      return canNotActiveToken =
          gameState.serverState!.currentTurn != liveToken.playerColor ||
              _isCellOccupiedBySamePlayer(
                gameState: gameState,
                liveToken: liveToken,
                otherToken: otherToken,
              ) ||
              _isCellHasTokenInSafeCell(
                gameState: gameState,
                liveToken: liveToken,
                otherToken: otherToken,
              ) ||
              targetPathIndex > 39 ||gameState.serverState!.turnStatus == TurnStatus.waitingForRoll;
    });
    return (!canNotActiveToken && liveToken.pathIndex!=-1)||
        (liveToken.pathIndex == -1 &&
            gameState.serverState!.lastDiceValue == 6&&!canNotActiveToken);
  }

  static bool _isCellOccupiedBySamePlayer({
    required Token liveToken,
    required Token otherToken,
    required GameState? gameState,
  }) {
    final targetPathIndex =
        liveToken.pathIndex + gameState!.serverState!.lastDiceValue.toInt();
    bool isSameToken =
        otherToken.id != liveToken.id &&
            otherToken.playerColor == liveToken.playerColor;
    return (isSameToken) &&
        ((otherToken.pathIndex == 0 &&
            liveToken.pathIndex == -1 &&
            gameState.serverState!.lastDiceValue == 6) ||
            (otherToken.pathIndex == targetPathIndex &&
                liveToken.pathIndex != -1 &&
                otherToken.pathIndex != 39));
  }

  static bool _isCellHasTokenInSafeCell({
    required Token liveToken,
    required Token otherToken,
    required GameState? gameState,
  }) {
    if (otherToken.playerColor == liveToken.playerColor) {
      return false;
    }
    final globalLiveTokenPathIndex = _globalPlayerIndex(
      pathIndex: liveToken.pathIndex,
      playerColor: liveToken.playerColor,
    );
    return globalLiveTokenPathIndex + gameState!.serverState!.lastDiceValue ==
        _playerStartIndex[otherToken.playerColor] &&
        otherToken.pathIndex == 0;
  }
}
