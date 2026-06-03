import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';

enum GameStatus { start, finished, waitingForPlayer }

enum TurnStatus {
  waitingForRoll,
  waitingForMove,
  waitingForAnimate,
  moveTokenRequestInFlight,
  rollDiceRequestInFlight,
}

class ServerState {
  final int gameMode;
  final TurnStatus turnStatus;
  final List<Token> tokens;
  final int lastDiceValue;
  final PlayerColor currentTurn;
  final GameStatus gameStatus;
  final List<Player> players;
  Player? winner;

  ServerState({
    this.winner,
    required this.gameMode,
    required this.turnStatus,
    required this.tokens,
    required this.lastDiceValue,
    required this.currentTurn,
    required this.gameStatus,
    required this.players,
  });

  factory ServerState.fromJson(Map<String, dynamic> json) {
    List tokensList = json['tokens'];
    Player? winner;
    if (json['winner'] != null && json['winner'] is Map) {
      winner = Player.fromJson(json['winner']);
    }
    return ServerState(
      gameMode: json['game_mode'],
      turnStatus: TurnStatus.values.byName(json['turn_status']),
      winner: winner,
      tokens: tokensList.map((t) => Token.fromJson(t)).toList(),
      lastDiceValue: json['last_dice_value'],
      currentTurn: PlayerColor.values.byName(json['current_turn']),
      gameStatus: GameStatus.values.byName(json['game_status']),
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
    TurnStatus? turnStatus,
    int? gameMode,
    Player? winner,
  }) {
    return ServerState(
      winner: winner ?? this.winner,
      gameMode: gameMode ?? this.gameMode,
      turnStatus: turnStatus ?? this.turnStatus,
      tokens: tokens ?? this.tokens,
      lastDiceValue: lastDiceValue ?? this.lastDiceValue,
      currentTurn: currentTurn ?? this.currentTurn,
      gameStatus: gameStatus ?? this.gameStatus,
      players: players ?? this.players,
    );
  }
}
