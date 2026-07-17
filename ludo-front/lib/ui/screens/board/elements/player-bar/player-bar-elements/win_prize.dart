import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class WinPrize extends ConsumerWidget {
  const WinPrize({super.key, required this.boardSize});
  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: boardSize * 0.02, vertical: boardSize * 0.01),
      decoration: BoxDecoration(
        color: const Color(0x1FFF0000),
        borderRadius: BorderRadius.circular(boardSize * 0.015),
        border: Border.all(color: const Color(0x8AFFD700), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, color: const Color(0xFFFFD700), size: boardSize * 0.03),
          SizedBox(width: boardSize * 0.01),
          Text(
            ref.watch(gameControllerProvider.select((s) => s!.winPrice().toString())),
            style: TextStyle(
              color: const Color(0xFFFFE082),
              fontWeight: FontWeight.bold,
              fontSize: boardSize * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}