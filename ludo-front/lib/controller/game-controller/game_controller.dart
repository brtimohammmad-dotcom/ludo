import 'package:flutter/cupertino.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';

import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

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
  VoidCallback? onGameFinished; // کالبک برای صفحه
  VoidCallback? onReconnectionFailed; // کالبک برای صفحه
  GameState? gameState;
  final GameRepository gameRepository = GameRepository();
  Player? livePlayer;
  AnimationController? animationController;

  // ✅ اضافه شده برای مدیریت وضعیت
  bool _isDisposed = false;
  bool _isGameFinishedHandled = false;
  bool _isMovingToken = false;

  GameController() {
    _setupCallbacks();
  }

  void _setupCallbacks() {
    gameRepository.dataSource.onStateUpdate = (ServerState state) {
      final newLivePlayer = state.players.firstWhere(
        (p) => p.userId == livePlayer!.userId,
      );
      if (_isDisposed) return;
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      notifyListeners();
    };

    gameRepository.dataSource.onTimesUp = (ServerState state) {
      final newLivePlayer = state.players.firstWhere(
        (p) => p.userId == livePlayer!.userId,
      );
      if (_isDisposed) return;
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      animationController?.reset();
      notifyListeners();
      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
    };

    gameRepository.dataSource.onGameFinished = (Player winner) {
      if (_isDisposed) return;
      animationController?.stop();
      final newGameState = gameState!.copyWith(
        livePlayer: livePlayer,
        serverState: gameState!.serverState.copyWith(winner: winner),
      );
      gameState = newGameState;
      notifyListeners();

      // ✅ جلوگیری از چندبار صدا زدن
      if (onGameFinished != null && !_isGameFinishedHandled) {
        _isGameFinishedHandled = true;
        onGameFinished!();
      }
    };
    gameRepository.dataSource.onReconnectionFailedCallback = () {
      if (_isDisposed) return;
      animationController?.stop();
      onReconnectionFailed!();
    };
    gameRepository.dataSource.onPlayerUpdate = (Player player) {
      if (_isDisposed) return;
      livePlayer = player;
      notifyListeners();
    };

    gameRepository.dataSource.onTokenMoved =
        (ServerState newSocketServerState) async {
          if (_isDisposed || _isMovingToken) return;

          _isMovingToken = true;
          try {
            animationController?.stop();
            await _moveTokenStepByStep(newSocketServerState);

            final newLivePlayer = newSocketServerState.players.firstWhere(
              (p) => p.userId == livePlayer!.userId,
            );
            livePlayer = newLivePlayer;

            gameState = GameState(
              serverState: newSocketServerState,
              livePlayer: newLivePlayer,
            );

            animationController?.reset();
            animationController?.forward();
            notifyListeners();
          } finally {
            _isMovingToken = false;
          }
        };

    gameRepository.dataSource.onDiceRolled =
        (ServerState newSocketServerState) async {
          if (_isDisposed) return;
          final newLivePlayer = newSocketServerState.players.firstWhere(
            (p) => p.userId == livePlayer!.userId,
          );

          animationController?.stop();
          ServerState changeTurnStatusServerState = gameState!.serverState
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
              livePlayer: livePlayer!,
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
                .serverState
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
        gameState!.serverState.turnStatus == TurnStatus.waitingForMove) {
      gameState = gameState!.copyWith(
        serverState: gameState!.serverState.copyWith(
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
      final newServerState = gameState!.serverState.copyWith(
        turnStatus: TurnStatus.rollDiceRequestInFlight,
      );
      gameState = gameState!.copyWith(serverState: newServerState);
      notifyListeners();
      gameRepository.rollDice();
    }
  }

  bool isMyTurnToRoll() {
    if (_isDisposed || gameState == null) return false;
    return gameState!.serverState.currentTurn == gameState!.livePlayer.color &&
        gameState!.serverState.turnStatus == TurnStatus.waitingForRoll &&
        gameState!.serverState.gameStatus == GameStatus.start;
  }

  Future<void> _moveTokenStepByStep(ServerState newSocketServerState) async {
    if (_isDisposed) return;
    final newLivePlayer = newSocketServerState.players.firstWhere(
      (p) => p.userId == livePlayer!.userId,
    );
    final newTokens = newSocketServerState.tokens;
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

    if (movedTokenIndex == null) {
      gameState = GameState(
        serverState: newSocketServerState,
        livePlayer: newLivePlayer,
      );
      return;
    }

    final oldPathIndex =
        gameState!.serverState.tokens[movedTokenIndex].pathIndex;

    for (int step = oldPathIndex; step < targetPathIndex!; step++) {
      if (_isDisposed) return;

      final currentToken = gameState!.serverState.tokens[movedTokenIndex];
      final updatedToken = currentToken.copyWith(pathIndex: step + 1);
      final updatedTokens = List<Token>.from(gameState!.serverState.tokens);
      updatedTokens[movedTokenIndex] = updatedToken;

      final newServerState = gameState!.serverState.copyWith(
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
    gameState = null;
    livePlayer?.color!=null?null:livePlayer?.color;
    livePlayer?.numberOfAbsences!=null?null:livePlayer?.numberOfAbsences;
    livePlayer?.playerStatus!=null?null:livePlayer?.playerStatus;
    livePlayer?.connectionStatus!=null?null:livePlayer?.connectionStatus;

    animationController?.stop();
    animationController = null;

    onGameFinished = null;

    notifyListeners();
  }

  // ✅ بررسی اینکه آیا controller هنوز فعال است
  bool get isDisposed => _isDisposed;
}
