import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/join_screen.dart';

enum GameStatus { start, finished, waitingForPlayer }

enum TurnStatus {
  waitingForRoll,
  waitingForMove,
  waitingForAnimate,
  moveTokenRequestInFlight,
  rollDiceRequestInFlight,
}

class ServerState {
  final int numberOfPlayers;
  final TurnStatus turnStatus;
  final List<Token> tokens;
  final int lastDiceValue;
  final PlayerColor currentTurn;
  final GameStatus gameStatus;
  final List<Player> players;
  final GameMode mode;
  Player? winner;
  String? invitationLink;

  ServerState({
    this.invitationLink,
    this.winner,
    required this.mode,
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
      invitationLink: json['invitationLink'],
      mode: GameMode.values.byName(json['game_mode']),
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
    String? invitationLink,
    GameMode? mode,
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
      invitationLink: invitationLink??this.invitationLink,
      mode: mode ?? this.mode,
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
