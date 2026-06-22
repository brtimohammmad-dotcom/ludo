import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/board/board-cell/board_background.dart';
import 'package:ludo/ui/elements/board/board-cell/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';
import 'package:ludo/ui/elements/token/create_animated_tokens.dart';

class MainBoard extends ConsumerWidget {
  const MainBoard({
    super.key,
    required this.boardSize,
    required this.diceComposition,
  });

  final Future<LottieComposition> diceComposition;

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);
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
                gameController: gameControllerNotifier,
              ),
            ],
          ),
          DiceWidget(
            cellSize: boardSize / 11,
            diceComposition: diceComposition,
          ),
        ],
      ),
    );
  }
}
