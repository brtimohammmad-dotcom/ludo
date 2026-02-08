
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/can-active-token/greater_than_final_path.dart';
import 'package:ludo/domain/rules/can-active-token/has_token_on_safe_cell_target.dart';
import 'package:ludo/domain/rules/can-active-token/is_cell_occupied_by_same_player.dart';

bool canActivateToken({
  required Token token,
  required List<Token> tokens,
  required Dice dice,
  required GameController gameController,
}) {
  final targetPathIndex = token.pathIndex + dice.value;

  bool newIsCellOccupiedBySamePlayer = isCellOccupiedBySamePlayer(
    tokens: tokens,
    token: token,
    dice: dice,
    targetPathIndex: targetPathIndex,
  );

  final newHasTokenOnTargetSafeCell = hasTokenOnTargetSafeCell(
    tokens: tokens,
    token: token,
    targetPathIndex: targetPathIndex,
  );
  final newGreaterThanFinalPath = greaterThanFinalPath(
    tokens: tokens,
    token: token,
    targetPathIndex: targetPathIndex,
  );
  final canNotMove =
      newIsCellOccupiedBySamePlayer ||
      newHasTokenOnTargetSafeCell ||
      newGreaterThanFinalPath;

  return token.player == gameController.currentPlayer.value &&
      (!token.isInHome || dice.value == 6) &&
      !canNotMove;
}
