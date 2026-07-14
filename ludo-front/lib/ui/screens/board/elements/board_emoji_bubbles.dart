import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/active_emoji_notifier/active_emoji_notifier.dart';
import 'package:ludo/ui/screens/board/elements/player_emoji_bubble.dart';

class BoardEmojiBubbles extends ConsumerWidget {
  final double cellSize;
  const BoardEmojiBubbles({super.key, required this.cellSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmojis = ref.watch(activeEmojiProvider);

    return Stack(
      children: [
        // حباب بازیکن آبی (بالا چپ بورد)
        Positioned(
          top: cellSize * 0.3,
          left: cellSize * 1.5,
          width: cellSize,
          height: cellSize,
          child: PlayerEmojiBubble(emoji: activeEmojis.blue ?? '', cellSize: cellSize * 0.8),
        ),

        // حباب بازیکن زرد (بالا راست بورد)
        Positioned(
          top: cellSize * 0.3,
          right: cellSize * 1.5,
          width: cellSize,
          height: cellSize,
          child: PlayerEmojiBubble(emoji: activeEmojis.yellow ?? '', cellSize: cellSize * 0.8),
        ),

        // حباب بازیکن قرمز (پایین چپ بورد)
        Positioned(
          bottom: cellSize * 0.3,
          left: cellSize * 1.5,
          width: cellSize,
          height: cellSize,
          child: PlayerEmojiBubble(emoji: activeEmojis.red ?? '', cellSize: cellSize * 0.8),
        ),

        // حباب بازیکن سبز (پایین راست بورد)
        Positioned(
          bottom: cellSize * 0.3,
          right: cellSize * 1.5,
          width: cellSize,
          height: cellSize,
          child: PlayerEmojiBubble(emoji: activeEmojis.green ?? '', cellSize: cellSize * 0.8),
        ),
      ],
    );
  }
}