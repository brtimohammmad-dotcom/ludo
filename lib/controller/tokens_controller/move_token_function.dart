import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

Future<void> moveTokenSafely({
  required TokensController tokenNotifier,
  required int pathIndex,
  required int player,
  required int tokenId,
  required int steps,
  required bool isInHome,
}) async {
  if (tokenNotifier.isMoving) return;
  tokenNotifier.isMoving = true;
  if (isInHome) {
    _moveTokenToStartCell(player, tokenId, tokenNotifier);
    debugPrint('tapped');

  } else {
    await _moveTokenStepByStep(
      player: player,
      tokenId: tokenId,
      steps: steps,
      tokenNotifier: tokenNotifier,
    );
  }

  tokenNotifier.isMoving = false;
}

void _moveTokenToStartCell(
  int player,
  int tokenId,
  TokensController tokenNotifier,
) {
  List<Token> newTokenNotifier = List<Token>.from(
    tokenNotifier.tokenNotifier.value,
  );
  switch (player) {
    case 1:
      newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
        isActive: false,
        newPathIndex: 0,
      );
      break;
    case 2:
      newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
        isActive: false,
        newPathIndex: 0,
      );
      break;
    case 3:
      newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
        isActive: false,
        newPathIndex: 0,
      );
      break;
    case 4:
      newTokenNotifier[tokenId - 1] = newTokenNotifier[tokenId - 1].copyWith(
        isActive: false,
        newPathIndex: 0,
      );
      break;
  }
}

Future<void> _moveTokenStepByStep({
  required int player,
  required int tokenId,
  required int steps,
  required TokensController tokenNotifier,
}) async {
  List<Token> current = List.from(tokenNotifier.tokenNotifier.value);

  int index = tokenId - 1;
  Token token = current[index];

  for (int i = 0; i < steps; i++) {
    if (token.pathIndex >= 57) {
      break;
    }
    token = token.copyWith(newPathIndex: token.pathIndex + 1);
    current[index] = token;
    for (Token token in current) {
      token.copyWith(isActive: false);
    }
    tokenNotifier.tokenNotifier.value = List.from(current);

    await Future.delayed(const Duration(milliseconds: 180));
  }
}
