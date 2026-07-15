import 'package:flutter/material.dart';

import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';

enum GameType { friendly, global }

enum GameLevel {
  free(
    displayName: "friendly",
    entryFee: 0,
    prize2P: 0,
    prize4P: 0,
    color: Colors.transparent,
  ),
  bronze(
    displayName: "Bronze",
    entryFee: 50,
    prize2P: 90,
    prize4P: 150,
    color: Color(0xFFCD7F32),
  ),
  silver(
    displayName: "Silver",
    entryFee: 200,
    prize2P: 360,
    prize4P: 600,
    color: Color(0xFFC0C0C0),
  ),
  gold(
    displayName: "Gold",
    entryFee: 500,
    prize2P: 900,
    prize4P: 1500,
    color: Color(0xFFFFD700),
  ),
  vip(
    displayName: "VIP",
    entryFee: 1000,
    prize2P: 1800,
    prize4P: 3000,
    color: Color(0xFFD4AF37),
  );

  final String displayName;
  final int entryFee;
  final int prize2P;
  final int prize4P;
  final Color color;

  const GameLevel({
    required this.displayName,
    required this.entryFee,
    required this.prize2P,
    required this.prize4P,
    required this.color,
  });
}

enum GameStatus { start, finished, waitingForPlayer, exit }

enum TurnStatus {
  waitingForRoll,
  waitingForMove,
  waitingForAnimate,
  moveTokenRequestInFlight,
  rollDiceRequestInFlight,
}

class ServerState {
  final int numberOfPlayers;
  final String gameId;
  final TurnStatus turnStatus;
  final List<Token> tokens;
  final int lastDiceValue;
  final PlayerColor currentTurn;
  final GameStatus gameStatus;
  final List<Player> players;
  final GameLevel level;
  final GameType type;
  Player? winner;

  ServerState({
    this.winner,
    required this.type,
    required this.level,
    required this.gameId,
    required this.numberOfPlayers,
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
      gameId: json['game_id'],
      type: GameType.values.byName(json['game_type']),
      level: GameLevel.values.byName(json['game_level']),
      numberOfPlayers: json['number_of_players'],
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
    String? gameId,
    GameType? type,
    GameLevel? level,
    List<Token>? tokens,
    int? lastDiceValue,
    PlayerColor? currentTurn,
    GameStatus? gameStatus,
    List<Player>? players,
    TurnStatus? turnStatus,
    int? numberOfPlayers,
    Player? winner,
  }) {
    return ServerState(
      gameId: gameId ?? this.gameId,
      type: type ?? this.type,
      level: level ?? this.level,
      winner: winner ?? this.winner,
      numberOfPlayers: numberOfPlayers ?? this.numberOfPlayers,
      turnStatus: turnStatus ?? this.turnStatus,
      tokens: tokens ?? this.tokens,
      lastDiceValue: lastDiceValue ?? this.lastDiceValue,
      currentTurn: currentTurn ?? this.currentTurn,
      gameStatus: gameStatus ?? this.gameStatus,
      players: players ?? this.players,
    );
  }
}
