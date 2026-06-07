import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';

import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

extension GameStateX on GameState {
  GameState toggleTurn() {
    return copyWith(
      serverState: serverState!.copyWith(
        currentTurn: serverState!.currentTurn.next,
      ),
    );
  }
}

class GameController extends ChangeNotifier {
  VoidCallback? onGameFinished; // کالبک برای صفحه
  VoidCallback? onReconnectionFailed; // کالبک برای صفحه
  VoidCallback? onPlayerExit; // کالبک برای صفحه
  GameState? gameState;
  final GameRepository gameRepository = GameRepository();
  AnimationController? animationController;

  // ✅ اضافه شده برای مدیریت وضعیت
  final bool _isDisposed = false;
  bool _isGameFinishedHandled = false;
  bool _isMovingToken = false;

  static final GameController _instance = GameController._internal();
  factory GameController() => _instance;
  GameController._internal() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    // state updated
    gameRepository.dataSource.onStateUpdate = (ServerState state) {
      final newLivePlayer = state.players.firstWhere(
        (p) => p.userId == gameState!.livePlayer!.userId,
      );
      if (_isDisposed) return;
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      debugPrint("state updated");
      notifyListeners();
    };
    // times up
    gameRepository.dataSource.onTimesUp = (ServerState state) {
      final newLivePlayer = state.players.firstWhere(
        (p) => p.userId == gameState!.livePlayer!.userId,
      );
      if (_isDisposed) return;
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      animationController?.reset();
      notifyListeners();
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      debugPrint("times up");
    };
    // game finished
    gameRepository.dataSource.onGameFinished = (Player winner) {
      if (_isDisposed) return;
      animationController?.stop();
      final newGameState = gameState!.copyWith(
        livePlayer: gameState!.livePlayer,
        serverState: gameState!.serverState!.copyWith(winner: winner),
      );
      gameState = newGameState;
      notifyListeners();

      if (onGameFinished != null && !_isGameFinishedHandled) {
        _isGameFinishedHandled = true;
        onGameFinished!();
      }
      debugPrint("game finished");
    };
    // connection failed
    gameRepository.dataSource.onReconnectionFailedCallback = () {
      if (_isDisposed) return;
      animationController?.stop();
      onReconnectionFailed!();
      debugPrint("reconnection failed");
    };
    // player initialized
    gameRepository.dataSource.onPlayerUpdate = (Player player) {
      if (_isDisposed) return;
      debugPrint("🎯 HIT! onPlayerUpdate Called. Player: ${player.username}");
      gameState = GameState(
        serverState: gameState?.serverState,
        livePlayer: player,
      );
      notifyListeners();
    };
    //  player exit
    gameRepository.dataSource.onPlayerExit = () {
      onPlayerExit!();
      notifyListeners();
      debugPrint("player exited");
    };
    //  token moved
    gameRepository.dataSource.onTokenMoved =
        (ServerState newSocketServerState) async {
          if (_isDisposed || _isMovingToken) return;

          _isMovingToken = true;
          try {
            animationController?.stop();
            await _moveTokenStepByStep(newSocketServerState);

            final newLivePlayer = newSocketServerState.players.firstWhere(
              (p) => p.userId == gameState!.livePlayer!.userId,
            );
            gameState!.copyWith(livePlayer: newLivePlayer);

            gameState = GameState(
              serverState: newSocketServerState,
              livePlayer: newLivePlayer,
            );

            animationController?.reset();
            animationController?.forward();
            notifyListeners();
            debugPrint("token moved");
          } finally {
            _isMovingToken = false;
          }
        };
    // dice rolled
    gameRepository.dataSource.onDiceRolled =
        (ServerState newSocketServerState) async {
          if (_isDisposed) return;
          final newLivePlayer = newSocketServerState.players.firstWhere(
            (p) => p.userId == gameState!.livePlayer!.userId,
          );

          animationController?.stop();
          ServerState changeTurnStatusServerState = gameState!.serverState!
              .copyWith(turnStatus: TurnStatus.rollDiceRequestInFlight);
          gameState = GameState(
            serverState: changeTurnStatusServerState,
            livePlayer: newLivePlayer,
          );
          notifyListeners();

          await Future.delayed(const Duration(milliseconds: 250));
          bool tokenIsActive = newSocketServerState.tokens.any((token) {
            GameState newGameState = GameState(
              serverState: newSocketServerState,
              livePlayer: gameState!.livePlayer,
            );
            return TokenRules.canActiveToken(token, newGameState);
          });

          if (tokenIsActive) {
            gameState = GameState(
              serverState: newSocketServerState,
              livePlayer: newLivePlayer,
            );
            animationController?.reset();
            notifyListeners();
          } else {
            ServerState changeLastDiceValueAndTurnStatusServerState = gameState!
                .serverState!
                .copyWith(
                  lastDiceValue: newSocketServerState.lastDiceValue,
                  turnStatus: TurnStatus.waitingForAnimate,
                );
            gameState = GameState(
              serverState: changeLastDiceValueAndTurnStatusServerState,
              livePlayer: newLivePlayer,
            );
            notifyListeners();

            await Future.delayed(const Duration(milliseconds: 750));

            gameState = GameState(
              serverState: newSocketServerState,
              livePlayer: newLivePlayer,
            );
            animationController?.reset();
            animationController?.forward();
            notifyListeners();
          }
          debugPrint("dice rolled");
        };
  }

  void startGame({required int gameMode}) {
    if (_isDisposed) return;
    gameRepository.startGame(gameMode);
  }

  void connectToGame() {
    gameRepository.onConnect();
  }

  void moveToken(Token liveToken) {
    if (_isDisposed) return;
    if (gameState != null &&
        gameState!.serverState!.turnStatus == TurnStatus.waitingForMove) {
      gameState = gameState!.copyWith(
        serverState: gameState!.serverState!.copyWith(
          turnStatus: TurnStatus.moveTokenRequestInFlight,
        ),
      );
      notifyListeners();
      gameRepository.moveToken(liveToken);
    }
  }

  void rollDice() {
    if (_isDisposed) return;
    if (gameState != null && isMyTurnToRoll()) {
      final newServerState = gameState!.serverState!.copyWith(
        turnStatus: TurnStatus.rollDiceRequestInFlight,
      );
      gameState = gameState!.copyWith(serverState: newServerState);
      notifyListeners();
      gameRepository.rollDice();
    }
  }

  bool isMyTurnToRoll() {
    if (_isDisposed || gameState == null) return false;
    return gameState!.serverState!.currentTurn ==
            gameState!.livePlayer!.color &&
        gameState!.serverState!.turnStatus == TurnStatus.waitingForRoll &&
        gameState!.serverState!.gameStatus == GameStatus.start;
  }

  Future<void> _moveTokenStepByStep(ServerState newSocketServerState) async {
    if (_isDisposed) return;
    final newLivePlayer = newSocketServerState.players.firstWhere(
      (p) => p.userId == gameState!.livePlayer!.userId,
    );
    final newTokens = newSocketServerState.tokens;
    int? movedTokenIndex;
    int? targetPathIndex;

    for (int i = 0; i < 16; i++) {
      final oldToken = gameState!.serverState!.tokens[i];
      final newToken = newTokens.firstWhere((t) => t.id == oldToken.id);
      if (newToken.pathIndex != oldToken.pathIndex &&
          newToken.playerColor == gameState!.serverState!.currentTurn) {
        movedTokenIndex = i;
        targetPathIndex = newToken.pathIndex;
        break;
      }
    }

    if (movedTokenIndex == null) {
      gameState = GameState(
        serverState: newSocketServerState,
        livePlayer: newLivePlayer,
      );
      return;
    }

    final oldPathIndex =
        gameState!.serverState!.tokens[movedTokenIndex].pathIndex;

    for (int step = oldPathIndex; step < targetPathIndex!; step++) {
      if (_isDisposed) return;

      final currentToken = gameState!.serverState!.tokens[movedTokenIndex];
      final updatedToken = currentToken.copyWith(pathIndex: step + 1);
      final updatedTokens = List<Token>.from(gameState!.serverState!.tokens);
      updatedTokens[movedTokenIndex] = updatedToken;

      final newServerState = gameState!.serverState!.copyWith(
        turnStatus: TurnStatus.waitingForAnimate,
        tokens: updatedTokens,
      );

      gameState = gameState!.copyWith(
        serverState: newServerState,
        livePlayer: newLivePlayer,
      );
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  // ✅ متد جدید برای خروج کامل از بازی
  void exitGame() async {
    if (_isDisposed) return;

    debugPrint("🎮 Exiting game...");
    gameRepository.exitGame();
  }

  void resetGame() {
    gameState!.serverState = null;
    gameState!.livePlayer!.color != null ? null : gameState!.livePlayer!.color;
    gameState!.livePlayer!.numberOfAbsences != null
        ? null
        : gameState!.livePlayer!.numberOfAbsences;
    gameState!.livePlayer!.playerStatus != null
        ? null
        : gameState!.livePlayer!.playerStatus;
    gameState!.livePlayer!.connectionStatus != null
        ? null
        : gameState!.livePlayer!.connectionStatus;

    animationController?.stop();
    animationController = null;
    onGameFinished = null;
    onReconnectionFailed = null;
    onPlayerExit = null;
  }

  // ✅ بررسی اینکه آیا controller هنوز فعال است
  bool get isDisposed => _isDisposed;
}
