class Token {
  final int id;
  final int player; // 1: red, 2: blue, 3: yellow, 4: green
  final int pathIndex;

  const Token._({
    required this.id,
    required this.player,
    required this.pathIndex,
  });

  factory Token.initial({
    required int id,
    required int player,
    required int pathIndex,
  }) {
    return Token._(
      id: id,
      player: player,
      pathIndex: -1,
    );
  }

  bool get isInHome => pathIndex == -1;

  Token copyWith({ int? newPathIndex}) {
    return Token._(
      id: id,
      player: player,
      pathIndex: newPathIndex ?? pathIndex,
    );
  }
}
