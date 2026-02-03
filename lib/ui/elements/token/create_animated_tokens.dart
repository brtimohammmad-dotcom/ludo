import 'package:flutter/material.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/game/logic/token-logic/token_logic.dart';
import 'package:ludo/ui/elements/token/token_widget.dart';
import 'package:ludo/domain/model/token.dart';

List<AnimatedPositioned> createAnimatedTokens(
  double cellSize,
  List<Token> tokens,
  TokensController controller,
) {
  return [
    ...tokens.map((token) {
      Offset cell;
      if (token.isInHome) {
        cell = homePaths[token.player]![((token.id-1)%4)];
      } else {
        cell = movementPaths[token.player]![token.pathIndex];
      }
      return AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        left: cell.dy * cellSize,
        top: cell.dx * cellSize,
        child: TokenWidget(
          token: token,
          size: cellSize,
          controller: controller,
        ),
      );
    }),
  ];
}
