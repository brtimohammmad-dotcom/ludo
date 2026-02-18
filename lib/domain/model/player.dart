import 'package:ludo/domain/model/token.dart';

enum PlayerStatus { waitingForRoll, waitingForMove, waitingForTurn,disconnected }

class Player {
  final String userId;
  final String username;
  final PlayerColor color;
  final List<Token> tokens;
  final PlayerStatus status;

  Player({
    required this.userId,
    required this.username,
    required this.color,
    required this.tokens,
    required this.status,
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
      status: PlayerStatus.values.byName(json['status']),
    );
  }

  Player copyWith({
    String? userId,
    String? username,
    PlayerColor? color,
    List<Token>? tokens,
    PlayerStatus? status,
  }) {
    return Player(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      color: color ?? this.color,
      tokens: tokens ?? this.tokens,
      status: status ?? this.status,
    );
  }
}
