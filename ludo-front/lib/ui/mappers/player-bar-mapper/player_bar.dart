import 'package:flutter/material.dart';
import 'player_bar_username_container.dart';
import 'roll_button.dart';
import 'exit_icon.dart';

class PlayerBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            if (leftPlayerIndex == 1 || leftPlayerIndex == -1)
              ExitIcon(boardSize: boardSize),
            if (leftPlayerIndex == 0)
              RollButton(boardSize: boardSize),
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