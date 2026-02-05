
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';

bool canActivateToken({
  required Token token,
  required List<Token> tokens,
  required Dice dice,
  required GameLogic gameLogic,
}) {
  final targetPathIndex = token.pathIndex + dice.random;
  bool isCellOccupiedBySamePlayer = tokens.any((other) {
    return (other.id != token.id && other.player == token.player) &&
        ((other.pathIndex == 0 && token.isInHome && dice.random == 6) ||
            (other.pathIndex == targetPathIndex && !token.isInHome));
  });
  // has problem
  bool hasTokenOnTargetSafeCell = tokens.any((other) {
    switch (token.player) {
      case 1:
        if (targetPathIndex == 13 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 2:
        if (targetPathIndex == 13 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 3:
        if (targetPathIndex == 13 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 4:
        if (targetPathIndex == 13 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      default:
        throw Exception('invalid Player');
    }
  });
  final canNotMove = isCellOccupiedBySamePlayer && hasTokenOnTargetSafeCell;

  return token.player == gameLogic.currentPlayerActiveNumber &&
      (!token.isInHome || dice.random == 6) &&
      !canNotMove;
}

void updateTokenActivation({
  required TokensController tokensController,
  required Dice dice,
  required GameLogic gameLogic,
}) {
  final tokens = tokensController.tokenNotifier.value;
  tokensController.tokenNotifier.value = tokens.map((token) {
    final canActivate = canActivateToken(
      token: token,
      tokens: tokens,
      dice: dice,
      gameLogic: gameLogic,
    );

    return token.copyWith(newIsActive: canActivate);
  }).toList();
}
