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
      padding: EdgeInsets.symmetric(
        horizontal: boardSize * 0.02,
        vertical: boardSize * 0.01,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.amber, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(boardSize * 0.015),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: boardSize * 0.03),
          SizedBox(width: boardSize * 0.01),
          Text(
            ref.watch(
              gameControllerProvider.select((s) {
                return s!.winPrice().toString();
              }),
            ),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: boardSize * 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
