import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/state/player_activation_state.dart';
import 'package:ludo/ui/elements/board-background/board_background.dart';
import 'package:ludo/ui/elements/board-background/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';

import 'package:ludo/ui/elements/token/create_animated_tokens.dart';

class Board extends StatelessWidget {
  Board({super.key});

  final TokensController tokensController = TokensController();
  final DiceController diceController = DiceController();
  final GameController gameController=GameController();
  final PlayerActivationState playerActivationState =
      PlayerActivationState();

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
                  const BoardBackground(),
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
                            cellSize: cellSize,
                          controller:  tokensController,
                           diceController:  diceController,
                           gameController:  gameController
                          ),
                        ],
                      );
                    },
                  ),
                  DiceWidget(
                    cellSize: cellSize,
                    diceController: diceController,
                    playerActivationState: playerActivationState,
                    tokensController: tokensController,
                    gameController: gameController,
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
