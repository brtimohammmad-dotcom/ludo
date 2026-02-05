import 'package:ludo/domain/model/token.dart';

bool greaterThanFinalPath({
  required List<Token> tokens,
  required Token token,
  required int targetPathIndex,
}) {
  return tokens.any((other) {
    return other.id == token.id &&
        token.player == other.player &&
        targetPathIndex > 57;
  });
}
