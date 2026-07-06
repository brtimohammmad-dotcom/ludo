import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

extension GameStateX on GameState? {
  bool get isMyTurnToRoll {
    if (this?.livePlayer == null || this?.serverState == null) return false;

    final s = this!.serverState!;
    return s.currentTurn == this!.livePlayer!.color &&
        s.turnStatus == TurnStatus.waitingForRoll &&
        s.gameStatus == GameStatus.start;
  }

  bool canTokenMove(Token token) {
    if (this == null) return false;
    if (this?.serverState == null || this?.livePlayer == null) return false;
    // شرط اول: نوبت من باشد
    if (this!.serverState!.currentTurn != this!.livePlayer!.color) return false;

    // شرط دوم: قوانین بازی اجازه حرکت به این مهره را بدهند
    return canActiveToken(token);
  }

  bool canActiveToken(Token token) {
    if (this == null) return false;
    if (this?.serverState == null || this?.livePlayer == null) return false;
    return TokenRules.canActiveToken(token, this!);
  }

  int getTargetTokensCountByColor(PlayerColor color) {
    if (this?.serverState == null) return 0;
    return this!.serverState!.tokens
        .where((t) => t.playerColor == color && t.pathIndex == 39)
        .length;
  }

  int reduceCoin() {
    final s = this!.serverState!;
    return s.numberOfPlayers == 2 ? 100 : 100;
  }

  int winPrice() {
    final s = this!.serverState;
    return s==null?0: s.numberOfPlayers == 2 ? 180 : 300;
  }
}

enum GameStage { connectionStage, joinStage, boardStage }

class GameState {
  final Player? livePlayer;
  final ServerState? serverState;
  final GameStage gameStage;

  GameState({
    required this.serverState,
    required this.livePlayer,
    this.gameStage = GameStage.connectionStage,
  });

  GameState copyWith({
    Player? livePlayer,
    ServerState? serverState,
    GameStage? gameStage,
  }) {
    return GameState(
      serverState: serverState ?? this.serverState,
      livePlayer: livePlayer ?? this.livePlayer,
      gameStage: gameStage ?? this.gameStage,
    );
  }
}
