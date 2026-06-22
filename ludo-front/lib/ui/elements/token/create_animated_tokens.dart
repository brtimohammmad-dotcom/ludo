import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/game/logic/token-logic/token_logic.dart';
import 'package:ludo/ui/elements/token/token_animated_widget.dart';

/// 🟢 ویجت واسطه برای آپدیت میکروسکوپی مختصات هر مهره به صورت مجزا
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
    // 🎯 جادوی ریورپاد: تماشای اختصاصی توکنی که آیدی آن با این ویجت برابر است
    final token = ref.watch(
      gameControllerProvider.select((state) {
        if (state?.serverState?.tokens == null) return null;
        // پیدا کردن مهره خاص از لیست سرور
        return state!.serverState!.tokens.firstWhere((t) => t.id == tokenId);
      }),
    );

    // اگر بازی هنوز کامل لود نشده یا مهره یافت نشد، چیزی رندر نمی‌کنیم
    if (token == null) return const SizedBox.shrink();

    // محاسبه دقیق مختصات مهره بر اساس دیتای سلکت شده و زنده
    Offset cell;
    if (token.pathIndex == -1) {
      cell = homePaths[token.playerColor.index]![((int.parse(token.id)) % 4)];
    } else {
      cell = movementPaths[token.playerColor.index]![token.pathIndex];
    }

    return TokenAnimatedWidget(
      key: ValueKey(token.id), // حفظ کلید اصلی برای جلوگیری از قاطی شدن ویجت‌ها در استک
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

/// 🟢 تابع اصلی تولید لیست مهره‌ها برای استفاده در استک بورد اصلی
List<Widget> createAnimatedTokens({
  required double cellSize,
  required GameController gameController,
}) {
  // اگر در ابتدای لود برنامه استیت خالی است، لیست تهی برمی‌گردانیم
  if (gameController.currentGameState?.serverState?.tokens == null) {
    return const [];
  }

  // نقشه کردن لیست توکن‌های اولیه به ویجت‌های واسطه
  return [
    ...gameController.currentGameState!.serverState!.tokens.map((token) {
      return TokenPositionWrapper(
        key: ValueKey("wrap_${token.id}"),
        tokenId: token.id,
        cellSize: cellSize,
      );
    }),
  ];
}