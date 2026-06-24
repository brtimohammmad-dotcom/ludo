import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/elements/board/board-cell/board_background.dart';
import 'package:ludo/ui/elements/board/board-cell/token-home/home_container_list.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';
import 'package:ludo/ui/elements/token/create_animated_tokens.dart';
import 'package:ludo/ui/elements/board/target_counter_widget.dart';

class MainBoard extends ConsumerWidget {
  const MainBoard({
    super.key,
    required this.boardSize,
  });

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);
    final cellSize = boardSize / 11;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          const BoardBackground(),
          ...getColorizeHomeContainerList(cellSize, cellSize * 4),
          ...getHomeContainerList(cellSize, cellSize * 4),
          Stack(
            children: [
              ...createAnimatedTokens(
                cellSize: cellSize,
                gameController: gameControllerNotifier,
              ),

              // تزریق کانترهای ایزوله شده (فقط مختصات پوزیشن‌ها را بر اساس برد خودت نهایی کن)
              TargetCounterWidget(
                playerColor: PlayerColor.red,
                positionLeft: cellSize * 5,
                positionTop: cellSize * 6,
              ),
              TargetCounterWidget(
                playerColor: PlayerColor.green,
                positionLeft: cellSize * 6,
                positionTop: cellSize * 5,
              ),
              TargetCounterWidget(
                playerColor: PlayerColor.yellow,
                positionLeft: cellSize * 5,
                positionTop: cellSize * 4,
              ),
              TargetCounterWidget(
                playerColor: PlayerColor.blue,
                positionLeft: cellSize * 4,
                positionTop: cellSize * 5,
              ),
            ],
          ),
          DiceWidget(
            cellSize: cellSize,
          ),
        ],
      ),
    );
  }
}