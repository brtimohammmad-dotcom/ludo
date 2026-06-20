
import 'package:flutter/material.dart';

enum PlayerColor { red, blue, yellow, green }
extension PlayerColorExtension on PlayerColor {
  Color toColor() {
    switch (this) {
      case PlayerColor.red:
        return Colors.red;
      case PlayerColor.green:
        return Colors.green;
      case PlayerColor.yellow:
        return Colors.yellow;
      case PlayerColor.blue:
        return Colors.blue;
    }
  }
}
extension NextPlayerColorExtension on PlayerColor {
  PlayerColor get next {
    final values = PlayerColor.values;
    return values[(index + 1) % values.length];
  }
}

class Token {
  final String id;
  final PlayerColor playerColor;
  final int pathIndex;

  const Token({
    required this.id,
    required this.playerColor,
    this.pathIndex = -1,
  });


  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'].toString(),
      playerColor: PlayerColor.values.firstWhere(
        (e) => e.toString().split('.').last == json['color'],
      ),
      pathIndex: json['position'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': playerColor.toString().split('.').last,
    'position': pathIndex,
  };

  bool get isInHome => pathIndex == -1;

  Token copyWith({int? pathIndex, bool? isActive}) {
    return Token(
      id: id,
      playerColor: playerColor,
      pathIndex: pathIndex ?? this.pathIndex,
    );
  }
}
