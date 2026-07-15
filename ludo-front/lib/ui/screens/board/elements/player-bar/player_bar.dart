import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/exit_icon.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/message_icon.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/player_bar_username_container.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/roll_button.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/win_prize.dart';


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
        (s) => s?.serverState?.type == GameType.friendly,
      ),
    );

    // آیا این نوار مربوط به سطر بالایی (رقیب‌ها) است؟
    final bool isTopBar = leftPlayerIndex != 0;

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

            if (isTopBar) ...[
              if (isFriendly)
                ExitIcon(boardSize: boardSize)
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: boardSize * 0.075),
                    WinPrize(boardSize: boardSize),
                    SizedBox(width: boardSize * 0.02),
                    ExitIcon(boardSize: boardSize),
                  ],
                ),
            ],

            if (leftPlayerIndex == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RollButton(boardSize: boardSize),
                  MessageIcon(),
                ],
              ),

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
