  import 'package:flutter/material.dart';
  import 'package:ludo/controller/game-controller/game_controller.dart';
  import 'package:ludo/game/logic/token-logic/token_logic.dart';
  import 'package:ludo/ui/elements/token/token_animated_widget.dart';

  List<Widget> createAnimatedTokens({
    required double cellSize,
    required GameController gameController,
  }) {
    return [
      ...gameController.gameState!.serverState!.tokens.map((token) {
        Offset cell;
        if (token.pathIndex == -1) {
          cell = homePaths[token.playerColor.index]![((int.parse(token.id)) % 4)];
        } else {
          cell = movementPaths[token.playerColor.index]![token.pathIndex];
        }
        return TokenAnimatedWidget(
          key: ValueKey(token.id), // مهمه! بدون key ویجت ها با هم قاطی میشن
          token: token,
          cellSize: cellSize,
          left: token.isInHome
              ? (cell.dy * cellSize) + (cellSize / 2)
              : cell.dy * cellSize,
          top: token.isInHome
              ? (cell.dx * cellSize) + (cellSize / 2)
              : cell.dx * cellSize,
          gameController: gameController,
        );
      }),
    ];
  }
