class Token {
  final int id;
  final int player; // 1: red, 2: blue, 3: yellow, 4: green
  final int pathIndex;
  final bool isActive;

  const Token._({
    required this.isActive,
    required this.id,
    required this.player,
    required this.pathIndex,
  });

  factory Token.initial({
    required int id,
    required int player,
    required int pathIndex,
    required bool isActive,
  }) {
    return Token._(id: id, player: player, pathIndex: -1, isActive: isActive);
  }

  bool get isInHome => pathIndex == -1;

  Token copyWith({int? newPathIndex, bool? newIsActive}) {
    return Token._(
      id: id,
      player: player,
      pathIndex: newPathIndex ?? pathIndex,
      isActive: newIsActive ?? isActive,
    );
  }
}
