import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/screens/board/elements/dice/dice_widget.dart';
import 'package:ludo/ui/screens/board/elements/emoji_box.dart';
import 'package:ludo/ui/screens/board/elements/token/create_animated_tokens.dart';
import 'package:ludo/ui/screens/board/painter/static_board_painter.dart';
// ایمپورت کامپوننت‌های جدیدی که در ادامه می‌سازیم:
import 'package:ludo/ui/screens/board/elements/board_target_counters.dart';
import 'package:ludo/ui/screens/board/elements/board_emoji_bubbles.dart';

class MainBoard extends ConsumerWidget {
  const MainBoard({super.key, required this.boardSize});

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellSize = boardSize / 11;

    // لود کردن آی‌دی‌های واقعی مهره‌ها از سرور
    final tokenIdsString = ref.watch(
      gameControllerProvider.select((state) {
        final tokens = state?.serverState?.tokens;
        if (tokens == null || tokens.isEmpty) return '';
        return tokens.map((t) => t.id).join(',');
      }),
    );
    final idList = tokenIdsString.isNotEmpty ? tokenIdsString.split(',') : <String>[];

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          // ۱. بک‌گراند بورد
          BoardBackground(),

          // ۲. لایه مهره‌ها و کانترهای هدف
          Stack(
            children: [
              ...idList.map((id) {
                return TokenPositionWrapper(
                  key: ValueKey("token_fixed_wrap_$id"),
                  tokenId: id,
                  cellSize: cellSize,
                );
              }),

              // 🎯 کانترها (ایزوله شده در یک ویجت اختصاصی)
              BoardTargetCounters(cellSize: cellSize),
            ],
          ),

          // ۳. لایه مستقل تاس
          DiceWidget(cellSize: cellSize),

          // 💬 ۴. لایه حباب‌های ایموجی بازیکنان (ایزوله شده در یک ویجت اختصاصی)
          BoardEmojiBubbles(cellSize: cellSize),

          // ۵. باکس انتخاب ایموجی
            EmojiBox(boardSize: boardSize, cellSize: cellSize),
        ],
      ),
    );
  }
}