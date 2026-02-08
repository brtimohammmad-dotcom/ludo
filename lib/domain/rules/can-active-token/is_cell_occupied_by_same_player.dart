import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/model/token.dart';

bool isCellOccupiedBySamePlayer({
  required List<Token> tokens,
  required Token token,
  required Dice dice,
  required int targetPathIndex,
}) {
  return tokens.any((other) {
    return (other.id != token.id && other.player == token.player) &&
        ((other.pathIndex == 0 && token.isInHome && dice.value == 6) ||
            (other.pathIndex == targetPathIndex && !token.isInHome&&other.pathIndex!=57));
  });
}
