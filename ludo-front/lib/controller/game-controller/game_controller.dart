import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ludo/data/data-source/socket_data_source.dart';
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
  /// UI Callbacks
  VoidCallback? onGameFinished;
  VoidCallback? onReconnectionFailed;
  VoidCallback? onPlayerExit;

  GameState? gameState;
  late GameRepository gameRepository;
  AnimationController? animationController;

  bool _isDisposed = false;
  bool _isGameFinishedHandled = false;
  bool _isMovingToken = false;

  GameController() {
    final ds = SocketDataSource();
    gameRepository = GameRepository(ds);
    _setupCallbacks();
  }

  // -------------------------------------------------
  // SETUP CALLBACKS
  // -------------------------------------------------
  void _setupCallbacks() {
    final ds = gameRepository.dataSource;

    // state updated
    ds.onStateUpdate = (ServerState state) {
      if (_isDisposed || gameState?.livePlayer == null) return;

      final newLivePlayer = state.players.firstWhere(
            (p) => p.userId == gameState!.livePlayer!.userId,
        orElse: () => gameState!.livePlayer!,
      );

      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      notifyListeners();
    };

    // times up
    ds.onTimesUp = (ServerState state) {
      if (_isDisposed || gameState?.livePlayer == null) return;

      final newLivePlayer = state.players.firstWhere(
            (p) => p.userId == gameState!.livePlayer!.userId,
        orElse: () => gameState!.livePlayer!,
      );

      gameState = GameState(serverState: state, livePlayer: newLivePlayer);
      animationController?.reset();
      notifyListeners();
    };

    // game finished
    ds.onGameFinished = (Player winner) {
      if (_isDisposed || gameState == null) return;

      animationController?.stop();

      gameState = gameState!.copyWith(
        serverState: gameState!.serverState!.copyWith(winner: winner),
      );

      notifyListeners();

      if (!_isGameFinishedHandled && onGameFinished != null) {
        _isGameFinishedHandled = true;
        onGameFinished!();
      }
    };

    // reconnection failed
    ds.onReconnectionFailedCallback = () {
      if (_isDisposed) return;
      animationController?.stop();
      onReconnectionFailed?.call();
    };

    // player initialized
    ds.onPlayerUpdate = (Player player) {
      if (_isDisposed) return;

      gameState = GameState(
        serverState: gameState?.serverState,
        livePlayer: player,
      );

      notifyListeners();
    };

    // player exit
    ds.onPlayerExit = () {
      if (_isDisposed) return;
      onPlayerExit?.call();
      notifyListeners();
    };

    // token moved
    ds.onTokenMoved = (ServerState newState) async {
      if (_isDisposed || _isMovingToken || gameState?.livePlayer == null) return;

      _isMovingToken = true;
      try {
        animationController?.stop();
        await _moveTokenStepByStep(newState);

        final newLivePlayer = newState.players.firstWhere(
              (p) => p.userId == gameState!.livePlayer!.userId,
          orElse: () => gameState!.livePlayer!,
        );

        gameState = GameState(serverState: newState, livePlayer: newLivePlayer);

        animationController?.reset();
        animationController?.forward();
        notifyListeners();
      } finally {
        _isMovingToken = false;
      }
    };

    // dice rolled
    ds.onDiceRolled = (ServerState newState) async {
      if (_isDisposed || gameState?.livePlayer == null) return;

      final newLivePlayer = newState.players.firstWhere(
            (p) => p.userId == gameState!.livePlayer!.userId,
        orElse: () => gameState!.livePlayer!,
      );

      animationController?.stop();

      gameState = GameState(
        serverState: gameState!.serverState!.copyWith(
          turnStatus: TurnStatus.rollDiceRequestInFlight,
        ),
        livePlayer: newLivePlayer,
      );

      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 250));

      final tokenIsActive = newState.tokens.any((token) {
        final newGameState = GameState(
          serverState: newState,
          livePlayer: gameState!.livePlayer,
        );
        return TokenRules.canActiveToken(token, newGameState);
      });

      if (tokenIsActive) {
        gameState = GameState(serverState: newState, livePlayer: newLivePlayer);
        animationController?.reset();
        notifyListeners();
      } else {
        gameState = GameState(
          serverState: gameState!.serverState!.copyWith(
            lastDiceValue: newState.lastDiceValue,
            turnStatus: TurnStatus.waitingForAnimate,
          ),
          livePlayer: newLivePlayer,
        );

        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 750));

        gameState = GameState(serverState: newState, livePlayer: newLivePlayer);
        animationController?.reset();
        animationController?.forward();
        notifyListeners();
      }
    };
  }

  // -------------------------------------------------
  // PUBLIC API
  // -------------------------------------------------
  void startGame({required int gameMode}) {
    if (_isDisposed) return;
    gameRepository.startGame(gameMode);
  }

  void connectToGame() {
    if (_isDisposed) return;
    gameRepository.connect();
  }

  void moveToken(Token liveToken) {
    if (_isDisposed || gameState == null) return;

    if (gameState!.serverState!.turnStatus == TurnStatus.waitingForMove) {
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
    if (_isDisposed || gameState == null) return;

    if (isMyTurnToRoll()) {
      gameState = gameState!.copyWith(
        serverState: gameState!.serverState!.copyWith(
          turnStatus: TurnStatus.rollDiceRequestInFlight,
        ),
      );
      notifyListeners();
      gameRepository.rollDice();
    }
  }

  bool isMyTurnToRoll() {
    if (_isDisposed || gameState == null || gameState!.livePlayer == null) {
      return false;
    }

    final s = gameState!.serverState!;
    return s.currentTurn == gameState!.livePlayer!.color &&
        s.turnStatus == TurnStatus.waitingForRoll &&
        s.gameStatus == GameStatus.start;
  }

  // -------------------------------------------------
  // TOKEN ANIMATION
  // -------------------------------------------------
  Future<void> _moveTokenStepByStep(ServerState newState) async {
    if (_isDisposed || gameState == null || gameState!.serverState == null) {
      return;
    }

    final newLivePlayer = newState.players.firstWhere(
          (p) => p.userId == gameState!.livePlayer!.userId,
      orElse: () => gameState!.livePlayer!,
    );

    final newTokens = newState.tokens;
    int? movedTokenIndex;
    int? targetPathIndex;

    for (int i = 0; i < gameState!.serverState!.tokens.length; i++) {
      final oldToken = gameState!.serverState!.tokens[i];
      final newToken = newTokens.firstWhere((t) => t.id == oldToken.id);

      if (newToken.pathIndex != oldToken.pathIndex &&
          newToken.playerColor == gameState!.serverState!.currentTurn) {
        movedTokenIndex = i;
        targetPathIndex = newToken.pathIndex;
        break;
      }
    }

    if (movedTokenIndex == null || targetPathIndex == null) {
      gameState = GameState(serverState: newState, livePlayer: newLivePlayer);
      return;
    }

    final oldPathIndex =
        gameState!.serverState!.tokens[movedTokenIndex].pathIndex;

    for (int step = oldPathIndex; step < targetPathIndex; step++) {
      if (_isDisposed || gameState == null || gameState!.serverState == null) {
        return;
      }

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

  // -------------------------------------------------
  // EXIT / RESET / DISPOSE
  // -------------------------------------------------
  void exitGame() {
    if (_isDisposed) return;
    gameRepository.exitGame();
  }

  void deleteGameState() {
    try {
      gameRepository.dataSource.dispose();
    } catch (_) {}

    final newDS = SocketDataSource();
    gameRepository = GameRepository(newDS);
    _setupCallbacks();

    animationController?.dispose();
    animationController = null;

    gameState = null;
    onGameFinished = null;
    onReconnectionFailed = null;
    onPlayerExit = null;

    _isGameFinishedHandled = false;
    _isMovingToken = false;

    notifyListeners();
  }

  void resetGame() {
    if (gameState?.livePlayer != null) {
      final clearedPlayer = Player(
        userId: gameState!.livePlayer!.userId,
        username: gameState!.livePlayer!.username,
        color: null,
        connectionStatus: null,
        playerStatus: null,
        numberOfAbsences: 0,
      );

      gameState = GameState(serverState: null, livePlayer: clearedPlayer);
    } else {
      gameState = null;
    }

    animationController?.dispose();
    animationController = null;

    onGameFinished = null;
    onReconnectionFailed = null;
    onPlayerExit = null;

    _isGameFinishedHandled = false;
    _isMovingToken = false;

    notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      gameRepository.dataSource.dispose();
    } catch (_) {}

    animationController?.dispose();
    super.dispose();
  }

  bool get isDisposed => _isDisposed;
}
