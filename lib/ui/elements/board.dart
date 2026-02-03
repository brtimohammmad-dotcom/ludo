import 'package:flutter/material.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/token_activation_controller.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/elements/board-background/board_background.dart';
import 'package:ludo/ui/elements/board-background/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';

import 'package:ludo/ui/elements/token/create_animated_tokens.dart';

class Board extends StatelessWidget {
  late final TokensController tokensController;
  late final TokenActivationController isActiveController;
  late final DiceController diceController;
  late final GameLogic gameLogic;

  Board({super.key}) {
    tokensController = TokensController();
    diceController = DiceController();
    isActiveController = TokenActivationController();
    gameLogic=GameLogic();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = constraints.maxWidth;
            final cellSize = boardSize / 15;
            final tokenHomeSize = cellSize * 4;
            final tokenColorizeHomeSize = cellSize * 6;
            return Container(
              color: Colors.white,
              child: Stack(
                children: [
                  BoardBackground(),
                  ...getColorizeHomeContainerList(
                    cellSize,
                    tokenColorizeHomeSize,
                  ),
                  ...getHomeContainerList(cellSize, tokenHomeSize),
                  ValueListenableBuilder(
                    valueListenable: tokensController.tokenNotifier,
                    builder: (context, tokens, _) {
                      return Stack(
                        children: [
                          ...createAnimatedTokens(
                            cellSize,
                            tokensController,
                            diceController,
                            gameLogic
                          ),
                        ],
                      );
                    },
                  ),
                  DiceWidget(
                    cellSize: cellSize,
                    diceController: diceController,
                    isActiveController: isActiveController,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
