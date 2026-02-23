import 'package:flutter/cupertino.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';

import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

extension GameStateX on GameState {
  GameState toggleTurn() {
    return copyWith(
      serverState: serverState.copyWith(
        currentTurn: serverState.currentTurn.next,
      ),
    );
  }
}

class GameController extends ChangeNotifier {
  GameState? gameState;
  final GameRepository gameRepository = GameRepository();
  Player? livePlayer;

  GameController() {
    // Set up callbacks to update game state when socket receives updates
    gameRepository.dataSource.onStateUpdate = (ServerState state) {
      final newSocketServerState = state;
      final newLivePlayer = newSocketServerState.players.firstWhere((p) {
        if (p.color == livePlayer!.color) {
          return true;
        }
        return false;
      });
      livePlayer = newLivePlayer;
      gameState = GameState(serverState: state, livePlayer: livePlayer!);
      notifyListeners();
    };

    gameRepository.dataSource.onPlayerUpdate = (Player player) {
      livePlayer = player;
    };
    gameRepository.dataSource.onTokenMoved =
        (ServerState newSocketServerState) async {
          //move token step by step
          await _moveTokenStepByStep(newSocketServerState);
          //change player state
          final newLivePlayer = newSocketServerState.players.firstWhere(
            (p) => p.color == livePlayer!.color,
          );
          livePlayer = newLivePlayer;
          //initial game state
          gameState = GameState(
            serverState: newSocketServerState,
            livePlayer: newLivePlayer,
          );
          notifyListeners();
        };
  }

  void startGame() {
    gameRepository.onConnect();
    // State will be updated via callbacks when socket connects
  }

  void moveToken(Token liveToken) {
    gameRepository.moveToken(liveToken);
  }

  void rollDice() {
    if (livePlayer!.playerStatus == PlayerStatus.waitingForRoll) {
      gameRepository.rollDice();
    }
  }

  bool isMyTurnToRoll() {
    return gameState!.serverState.currentTurn == gameState!.livePlayer.color &&
        gameState!.livePlayer.playerStatus == PlayerStatus.waitingForRoll;
  }

  Future<void> _moveTokenStepByStep(ServerState newSocketServerState) async {
    final newTokens = newSocketServerState.tokens;
    // پیدا کردن توکنی که جابجا شده (همان id، pathIndex متفاوت)
    int? movedTokenIndex;
    int? targetPathIndex;
    for (int i = 0; i < 16; i++) {
      final oldToken = gameState!.serverState.tokens[i];
      final newToken = newTokens.firstWhere((t) => t.id == oldToken.id);
      if (newToken.pathIndex != oldToken.pathIndex &&
          newToken.playerColor == gameState!.serverState.currentTurn) {
        movedTokenIndex = i;
        targetPathIndex = newToken.pathIndex;
        break;
      }
    }
    if (movedTokenIndex == null || targetPathIndex == null) {
      gameState = GameState(
        serverState: newSocketServerState,
        livePlayer: livePlayer!,
      );
      return;
    }
    final oldPathIndex =
        gameState!.serverState.tokens[movedTokenIndex].pathIndex;
    livePlayer = livePlayer!.copyWith(playerStatus: PlayerStatus.tokenIsMoving);
    debugPrint('old index : $oldPathIndex');
    debugPrint('target index : $targetPathIndex');
    for (int step = oldPathIndex; step < targetPathIndex; step++) {
      final currentToken = gameState!.serverState.tokens[movedTokenIndex];
      final updatedToken = currentToken.copyWith(pathIndex: step + 1);
      final updatedTokens = List<Token>.from(gameState!.serverState.tokens);
      updatedTokens[movedTokenIndex] = updatedToken;
      final newServerState = gameState!.serverState.copyWith(
        tokens: updatedTokens,
      );
      gameState = GameState(
        serverState: newServerState,
        livePlayer: livePlayer!,
      );
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  bool canActiveToken(Token liveToken) {
    final targetPathIndex =
        liveToken.pathIndex + gameState!.serverState.lastDiceValue!.toInt();
    bool canNotActiveToken = false;
    gameState!.serverState.tokens.any((otherToken) {
      return canNotActiveToken =
          livePlayer!.color != liveToken.playerColor ||
          _isCellOccupiedBySamePlayer(
            liveToken: liveToken,
            otherToken: otherToken,
          ) ||
          _isCellHasTokenInSafeCell(
            otherToken: otherToken,
            liveToken: liveToken,
          ) ||
          _isCellHasTokenInSafeCell(
            liveToken: liveToken,
            otherToken: otherToken,
          ) ||
          targetPathIndex > 39;
    });
    return !canNotActiveToken &&
            (liveToken.pathIndex != -1 ||
                gameState!.serverState.lastDiceValue == 6) &&
        gameState!.livePlayer.playerStatus == PlayerStatus.waitingForMove;
  }

  bool _isCellOccupiedBySamePlayer({
    required Token liveToken,
    required Token otherToken,
  }) {
    final targetPathIndex =
        liveToken.pathIndex + gameState!.serverState.lastDiceValue!.toInt();
    bool isSameToken =
        otherToken.id != liveToken.id &&
        otherToken.playerColor == liveToken.playerColor;
    return (isSameToken) &&
        ((otherToken.pathIndex == 0 &&
                liveToken.pathIndex == -1 &&
                gameState!.serverState.lastDiceValue == 6) ||
            (otherToken.pathIndex == targetPathIndex &&
                liveToken.pathIndex != -1 &&
                otherToken.pathIndex != 39));
  }

  final Map<PlayerColor, int> _playerStartIndex = {
    PlayerColor.red: 0, // قرمز
    PlayerColor.blue: 9, // آبی
    PlayerColor.yellow: 18, // زرد
    PlayerColor.green: 27, // سبز
  };
  final int _mainTrackLength = 36;

  int _globalPlayerIndex({
    required int pathIndex,
    required PlayerColor playerColor,
  }) {
    return (_playerStartIndex[playerColor]! + pathIndex) % _mainTrackLength;
  }

  bool _isCellHasTokenInSafeCell({
    required Token liveToken,
    required Token otherToken,
  }) {
    if (otherToken.playerColor == liveToken.playerColor) {
      return false;
    }
    final globalLiveTokenPathIndex = _globalPlayerIndex(
      pathIndex: liveToken.pathIndex,
      playerColor: liveToken.playerColor,
    );
    return globalLiveTokenPathIndex + gameState!.serverState.lastDiceValue! ==
            _playerStartIndex[otherToken.playerColor] &&
        otherToken.pathIndex == 0;
  }


  @override
  void dispose() {
    gameRepository.dispose();
    super.dispose();
  }
}
