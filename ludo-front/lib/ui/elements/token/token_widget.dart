import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends ConsumerWidget {
  final Token token;
  final double size;

  const TokenWidget({super.key, required this.token, required this.size});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool highlight = ref.watch(
      gameControllerProvider.select((state) => state.canTokenMove(token)),
    );
    final bool tokenIsActive = ref.watch(
      gameControllerProvider.select((state) => state.canActiveToken(token)),
    );

    final gameController = ref.read(gameControllerProvider.notifier);
    final centralController = gameController.animationController;

    void onTap() {
      if (highlight) {
        ref.read(gameControllerProvider.notifier).moveToken(token);
      }
    }

    final double currentMargin = tokenIsActive ? size / 9 : size / 5;
    final double innerSize = size - (currentMargin * 2);

    // ⚡ بهینه‌سازی کلیدی: بدنه ثابت مهره را یک‌بار اینجا می‌سازیم تا در انیمیشن ریبلد نشود
    final Widget staticTokenBody = Container(
      margin: EdgeInsets.all(currentMargin),
      decoration: BoxDecoration(
        gradient: tokenGradient(token), // فقط یک‌بار اجرا می‌شود
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xBFFFFFFF), // معادل Colors.white.withValues(alpha: 0.75) ثابت
          width: size / 15,
        ),
      ),
      child: Stack(
        children: [
          // ۱. رفلکس نوری هلالی
          Positioned(
            top: innerSize * 0.05,
            left: innerSize * 0.08,
            child: Container(
              width: innerSize * 0.45,
              height: innerSize * 0.2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x73FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
          // ۲. حلقه نوری داخلی
          Center(
            child: Container(
              width: innerSize * 0.45,
              height: innerSize * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x26FFFFFF),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // ۳. آیکون مرکز
          Center(
            child: highlight
                ? Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: size * 0.45,
              shadows: const [
                Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 2)
              ],
            )
                : const SizedBox(),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: (highlight && centralController != null)
            ? AnimatedBuilder(
          animation: centralController,
          child: staticTokenBody, // 🟢 پاس دادن به عنوان child ثابت
          builder: (context, child) {
            final double cycle = (centralController.value * 10) / 1.1;
            final double progress = cycle - cycle.floor();
            final double pingPongValue = (progress - 0.5).abs() * 2;

            final double currentGlow = 0.3 + (pingPongValue * 0.7);
            final double currentBounce = -6 * pingPongValue;

            return Transform.translate(
              offset: Offset(0, currentBounce),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: currentGlow),
                      blurRadius: 10 + currentGlow * 10,
                      spreadRadius: 1 + currentGlow * 2,
                    ),
                  ],
                ),
                child: child, // لایه‌های سنگین داخلی بدون ریبلد شدن اینجا قرار می‌گیرند
              ),
            );
          },
        )
            : DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (tokenIsActive)
                const BoxShadow(color: Colors.white, blurRadius: 6, spreadRadius: 1)
              else
                const BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(-2, 3)),
            ],
          ),
          child: staticTokenBody,
        ),
      ),
    );
  }
}