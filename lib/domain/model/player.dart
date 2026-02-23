import 'package:ludo/domain/model/token.dart';

enum PlayerStatus {
  waitingForRoll,
  diceIsRolling,
  waitingForMove,
  tokenIsMoving,
  waitingForTurn,
  disconnected,
}

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

class Player {
  final String userId;
  final String username;
  final PlayerColor color;
  final List<Token> tokens;
  final PlayerStatus playerStatus;
  final ConnectionStatus connectionStatus;

  Player({
    required this.userId,
    required this.username,
    required this.color,
    required this.tokens,
    required this.playerStatus,
    required this.connectionStatus
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    List<Token> tokenList = (json['tokens'] as List).map((token) {
      return Token.fromJson(token);
    }).toList();
    return Player(
      username: json['username'],
      color: PlayerColor.values.byName(json['color']),
      tokens: tokenList,
      userId: json['userId'].toString(),
      playerStatus: PlayerStatus.values.byName(json['status']),
      connectionStatus: ConnectionStatus.connected
    );
  }

  Player copyWith({
    String? userId,
    String? username,
    PlayerColor? color,
    List<Token>? tokens,
    PlayerStatus? playerStatus,
    ConnectionStatus? connectionStatus
  }) {
    return Player(
      connectionStatus: connectionStatus??this.connectionStatus,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      color: color ?? this.color,
      tokens: tokens ?? this.tokens,
      playerStatus: playerStatus ?? this.playerStatus,
    );
  }
}
