import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/game/logic/token-logic/token_logic.dart';
import 'package:ludo/ui/screens/board/elements/token/token_animated_widget.dart';

class TokenPositionWrapper extends ConsumerWidget {
  const TokenPositionWrapper({
    super.key,
    required this.tokenId,
    required this.cellSize,
  });

  final String tokenId;
  final double cellSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // استفاده از select بسیار دقیق؛ این ویجت فقط و فقط در صورتی ری‌بیلد می‌شود
    // که مختصات یا وضعیت همین یک مهره خاص تغییر کرده باشد.
    final token = ref.watch(
      gameControllerProvider.select((state) {
        if (state?.serverState?.tokens == null) return null;
        try {
          return state!.serverState!.tokens.firstWhere((t) => t.id == tokenId);
        } catch (_) {
          return null; // جلوگیری از کرش در صورتی که دیتای توکن هنوز سینک نشده باشد
        }
      }),
    );

    // اگر دیتای بازی هنوز لود نشده، ویجت خالی رندر می‌شود اما جایگاهش در استک حفظ می‌شود
    if (token == null) return const SizedBox.shrink();

    // محاسبه دقیق مختصات مهره بر اساس دیتای زنده
    Offset cell;
    if (token.pathIndex == -1) {
      cell = homePaths[token.playerColor.index]![((int.parse(token.id)) % 4)];
    } else {
      cell = movementPaths[token.playerColor.index]![token.pathIndex];
    }

    return TokenAnimatedWidget(
      key: ValueKey(token.id), // حفظ هویت منحصربه‌فرد ویجت در گرافیک فلاتر
      token: token,
      cellSize: cellSize,
      left: token.isInHome
          ? (cell.dy * cellSize) + (cellSize / 2)
          : cell.dy * cellSize,
      top: token.isInHome
          ? (cell.dx * cellSize) + (cellSize / 2)
          : cell.dx * cellSize,
    );
  }
}