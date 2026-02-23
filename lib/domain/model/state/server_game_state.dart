import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';

enum GameStatus {start, finished, waitingForPlayer }

class ServerState {
  final List<Token> tokens;
  final int? lastDiceValue;
  final PlayerColor currentTurn;
  final GameStatus gameStatus;
  final List<Player> players;

  ServerState({
    required this.tokens,
    this.lastDiceValue,
    required this.currentTurn,
    required this.gameStatus,
    required this.players,
  });

  factory ServerState.fromJson(Map<String, dynamic> json) {
    return ServerState(
      tokens: (json['tokens'] as List).map((t) => Token.fromJson(t)).toList(),
      lastDiceValue: json['lastDiceValue'],
      currentTurn: PlayerColor.values.byName(json['currentTurn']),
      gameStatus: GameStatus.values.byName(json['gameStatus']),
      players: (json['players'] as List)
          .map((p) => Player.fromJson(p))
          .toList(),
    );
  }

  ServerState copyWith({
    List<Token>? tokens,
    int? lastDiceValue,
    PlayerColor? currentTurn,
    GameStatus? gameStatus,
    List<Player>? players,
  }) {
    return ServerState(
      tokens: tokens ?? this.tokens,
      lastDiceValue: lastDiceValue ?? this.lastDiceValue,
      currentTurn: currentTurn ?? this.currentTurn,
      gameStatus: gameStatus ?? this.gameStatus,
      players: players ?? this.players,
    );
  }
}
