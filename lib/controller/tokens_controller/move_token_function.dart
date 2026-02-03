import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

Future<void> moveTokenSafely({
  required TokensController tokenNotifier,
  required Token token,
}) async {
  bool isInHome = token.isInHome;
  int tokenId = token.id;
  int steps = 3;
  if (!tokenNotifier.isMoving) {
    if (isInHome) {
      _moveTokenToStartCell(tokenId, tokenNotifier);
    } else {
      await _moveTokenStepByStep(
        tokenId: tokenId,
        steps: steps,
        tokenNotifier: tokenNotifier,
      );
    }
  }
}

Future<void> _moveTokenToStartCell(
  int tokenId,
  TokensController tokenNotifier,
) async {
  if (!tokenNotifier.isMoving) {
    tokenNotifier.isMoving = true;
    List<Token> newTokenNotifier = List<Token>.from(
      tokenNotifier.tokenNotifier.value,
    );
    newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
      isActive: false,
      newPathIndex: 0,
    );
    tokenNotifier.tokenNotifier.value = newTokenNotifier;
    await Future.delayed(const Duration(milliseconds: 300));
    tokenNotifier.isMoving = false;
  }
}

Future<void> _moveTokenStepByStep({
  required int tokenId,
  required int steps,
  required TokensController tokenNotifier,
}) async {
  if (!tokenNotifier.isMoving) {
    List<Token> current = List.from(tokenNotifier.tokenNotifier.value);

    int index = tokenId - 1;
    Token token = current[index];

    for (int i = 0; i < steps; i++) {
      if (token.pathIndex >= 57) {
        break;
      }
      tokenNotifier.isMoving = true;
      token = token.copyWith(newPathIndex: token.pathIndex + 1);
      current[index] = token;
      tokenNotifier.tokenNotifier.value = List.from(current);

      await Future.delayed(const Duration(milliseconds: 300));
      tokenNotifier.isMoving = false;
    }
  }
}
