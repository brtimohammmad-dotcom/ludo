import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/ui/elements/board-background/board_background.dart';
import 'package:ludo/ui/elements/board-background/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';
import 'package:ludo/ui/elements/token/create_animated_tokens.dart';

class Board extends StatelessWidget {
  final GameController gameController;

  const Board({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 1,sigmaY: 1),
            child: Image.asset('assets/images/background/background.png'),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final boardSize = constraints.maxWidth;
                  final cellSize = boardSize / 11;
                  final tokenHomeSize = cellSize * 4;
                  final tokenColorizeHomeSize = cellSize * 4;
                  return ListenableBuilder(
                    listenable: gameController,
                    builder: (context, child) {
                      if (gameController.gameState == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
                            const BoardBackground(),
                            ...getColorizeHomeContainerList(
                              cellSize,
                              tokenColorizeHomeSize,
                            ),
                            ...getHomeContainerList(cellSize, tokenHomeSize),
                            Stack(
                              children: [
                                ...createAnimatedTokens(
                                  cellSize: cellSize,
                                  gameController: gameController,
                                ),
                              ],
                            ),
                            DiceWidget(
                              cellSize: cellSize,
                              gameController: gameController,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
