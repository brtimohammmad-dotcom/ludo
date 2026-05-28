import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/board/board-cell/board_background.dart';
import 'package:ludo/ui/elements/board/board-cell/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';
import 'package:ludo/ui/elements/token/create_animated_tokens.dart';

class MainBoard extends StatelessWidget {
  const MainBoard({
    super.key,
    required this.boardSize,
    required this.gameController,
  });

  final double boardSize;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          const BoardBackground(),
          ...getColorizeHomeContainerList(boardSize / 11, (boardSize / 11) * 4),
          ...getHomeContainerList(boardSize / 11, (boardSize / 11) * 4),
          Stack(
            children: [
              ...createAnimatedTokens(
                cellSize: boardSize / 11,
                gameController: gameController,
              ),
            ],
          ),
          DiceWidget(cellSize: boardSize / 11, gameController: gameController),
        ],
      ),
    );
  }
}
