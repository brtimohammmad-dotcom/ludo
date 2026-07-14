import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'start_game_button.dart';

class GameSelectionButtons extends ConsumerWidget {
  final double boardSize;
  final dynamic handler; // کلاس JoinScreenHandler شما

  const GameSelectionButtons({
    super.key,
    required this.boardSize,
    required this.handler,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دکمه ۲ نفره عمومی
            StartGameButton(
              numberOfPlayers: 2,
              entryFee: 100,
              prizePool: 180,
              onPressed: () => handler.handleGameSearch(2, boardSize),
              boardSize: boardSize,
            ),
            SizedBox(width: boardSize * 0.03), // کمی فاصله بیشتر برای قرینگی زیباتر
            // دکمه ۴ نفره عمومی
            StartGameButton(
              entryFee: 100,
              prizePool: 300,
              numberOfPlayers: 4,
              onPressed: () => handler.handleGameSearch(4, boardSize),
              boardSize: boardSize,
            ),
          ],
        ),
      ],
    );
  }
}