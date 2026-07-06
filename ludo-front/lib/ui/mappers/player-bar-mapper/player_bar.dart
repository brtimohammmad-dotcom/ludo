import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';
import 'package:ludo/ui/mappers/player-bar-mapper/win_prize.dart';
import 'player_bar_username_container.dart';
import 'roll_button.dart';
import 'exit_icon.dart';

class PlayerBar extends ConsumerWidget {
  const PlayerBar({
    super.key,
    required this.boardSize,
    required this.barHeight,
    required this.leftPlayerIndex,
    required this.rightPlayerIndex,
  });

  final int leftPlayerIndex;
  final int rightPlayerIndex;
  final double boardSize;
  final double barHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFriendly = ref.watch(
      gameControllerProvider.select(
        (s) => s?.serverState?.mode == GameMode.friendly,
      ),
    );
    return Container(
      width: boardSize,
      height: barHeight,
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: boardSize * 0.037),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerBarUsernameContainer(
              boardSize: boardSize,
              playerIndex: leftPlayerIndex,
              barHeight: barHeight,
            ),

            if ((leftPlayerIndex == 1 || leftPlayerIndex == -1)&&isFriendly)
              ExitIcon(boardSize: boardSize),
            if ((leftPlayerIndex == -1 || leftPlayerIndex == -1)&&!isFriendly)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: boardSize * 0.075),
                  WinPrize(boardSize: boardSize),
                  SizedBox(width: boardSize * 0.02),
                  ExitIcon(boardSize: boardSize),
                ],
              ),

            if (leftPlayerIndex == 0) RollButton(boardSize: boardSize),

            PlayerBarUsernameContainer(
              boardSize: boardSize,
              playerIndex: rightPlayerIndex,
              barHeight: barHeight,
            ),
          ],
        ),
      ),
    );
  }
}
