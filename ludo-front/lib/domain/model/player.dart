import 'package:ludo/domain/model/token.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

enum PlayerStatus { online, offline }

class Player {
  final int userId;
  final String username;
  final PlayerColor? color;
  final ConnectionStatus? connectionStatus;
  final PlayerStatus? playerStatus;
  final int? numberOfAbsences;

  Player({
    required this.numberOfAbsences,
    required this.userId,
    required this.username,
    required this.color,
    required this.connectionStatus,
    required this.playerStatus,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      numberOfAbsences: json['numberOfAbsences'],
      username: json['username'],
      color: json['color'] == null
          ? null
          : PlayerColor.values.byName(json['color']),
      userId: json['telegram_id'],
      playerStatus: json['player_status'] == null
          ? null
          : PlayerStatus.values.byName(json['player_status']),
      connectionStatus: json['connection_status'] == null
          ? null
          : ConnectionStatus.values.byName(json['connection_status']),
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'telegram_id': userId,
  };

  Player copyWith({
    int? userId,
    String? username,
    PlayerColor? color,
    ConnectionStatus? connectionStatus,
    PlayerStatus? playerStatus,
    int? numberOfAbsences,
  }) {
    return Player(
      numberOfAbsences: numberOfAbsences ?? this.numberOfAbsences,
      playerStatus: playerStatus ?? this.playerStatus,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      color: color ?? this.color,
    );
  }
}
