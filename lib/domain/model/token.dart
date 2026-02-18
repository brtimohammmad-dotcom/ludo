
enum PlayerColor { red, blue, yellow, green }

extension PlayerColorExtension on PlayerColor {
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
      id: json['id'],
      playerColor: PlayerColor.values.firstWhere(
        (e) => e.toString().split('.').last == json['color'],
      ),
      pathIndex: json['position'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'playerColor': playerColor.toString().split('.').last,
    'pathIndex': pathIndex,
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
