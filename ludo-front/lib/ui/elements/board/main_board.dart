import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/elements/board/static_game_board.dart';
import 'package:ludo/ui/elements/dice/dice_widget.dart';
import 'package:ludo/ui/elements/token/create_animated_tokens.dart';
import 'package:ludo/ui/elements/board/target_counter_widget.dart';

class MainBoard extends ConsumerWidget {
  const MainBoard({super.key, required this.boardSize});

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellSize = boardSize / 11;

    // 🎯 لود کردن آی‌دی‌های واقعی مهره‌ها از سرور به صورت یک رشته یکپارچه
    // این تکه کد فقط یک‌بار زمان لود اولیه بازی مهره‌ها را می‌سازد و با حرکت مهره‌ها هرگز دوباره اجرا نمی‌شود (حفظ ۱۰۰٪ ریسورس)
    final tokenIdsString = ref.watch(gameControllerProvider.select((state) {
      final tokens = state?.serverState?.tokens;
      if (tokens == null || tokens.isEmpty) return '';
      return tokens.map((t) => t.id).join(','); // تبدیل به رشته مثل: "101,102,103..."
    }));

    // تبدیل رشته آی‌دی‌ها به لیست برای رندر کردن
    final idList = tokenIdsString.isNotEmpty ? tokenIdsString.split(',') : <String>[];

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          // ۱. بک‌گراند ثابت بازی (جدول و خانه‌ها) درون یک ری‌پینت‌باندری واحد کش شده است
          StaticGameBoard(cellSize: cellSize, tokenHomeSize: cellSize * 4),

          // ۲. لایه پویا و متحرک بازی (مهره‌ها و کانترها)
          Stack(
            children: [
              // رندر کردن مهره‌ها بر اساس آی‌دی‌های کاملاً واقعی و زنده سرور شما
              ...idList.map((id) {
                return TokenPositionWrapper(
                  key: ValueKey("token_fixed_wrap_$id"),
                  tokenId: id,
                  cellSize: cellSize,
                );
              }),

              // تزریق کانترهای ایزوله شده
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

          // ۳. لایه مستقل تاس بازی
          DiceWidget(cellSize: cellSize),
        ],
      ),
    );
  }
}