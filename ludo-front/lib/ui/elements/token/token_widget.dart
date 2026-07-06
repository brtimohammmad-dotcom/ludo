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
    // گوش دادن مانیتور شده به وضعیت مهره
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

    // 🟢 متد کمکی لایوت اصلی مهره با اعمال رفلکس سه‌بعدیِ مینیمال در لایه‌های داخلی
    Widget buildTokenBody({required double bounce, required double glow}) {
      final double currentMargin = tokenIsActive ? size / 9 : size / 5;
      final double innerSize = size - (currentMargin * 2);

      return Transform.translate(
        offset: Offset(0, bounce),
        child: Container(
          // حفظ دقیق مارجین‌های اصلی طرح اول شما جهت فیت شدن کامل روی بورد
          margin: EdgeInsets.all(currentMargin),
          decoration: BoxDecoration(
            gradient: tokenGradient(token),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.75), // شفافیت کنترل‌شده برای استروک دور
              width: size / 15,
            ),
            boxShadow: [
              if (highlight)
                BoxShadow(
                  color: Colors.white.withValues(alpha: glow),
                  blurRadius: 12 + glow * 16,
                  spreadRadius: 2 + glow * 4,
                )
              else if (tokenIsActive)
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              else
                const BoxShadow(
                  color: Colors.black38,
                  blurRadius: 2,
                  offset: Offset(-2, 3), // همان سایه اصلی و کلاسیک شما روی بورد
                ),
            ],
          ),
          // 💎 استفاده از Stack داخلی برای تزریقِ افکت سه‌بعدی متالیک بدون دستکاری بدنه اصلی
          child: Stack(
            children: [
              // ۱. رفلکس نوریِ هلالی (Glossy Highlight) بالا سمت چپ
              Positioned(
                top: innerSize * 0.05,
                left: innerSize * 0.08,
                child: Container(
                  width: innerSize * 0.45,
                  height: innerSize * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.45),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // ۲. حلقه نوری داخلی ظریف برای عمق دادن به مرکز مهره
              Center(
                child: Container(
                  width: innerSize * 0.45,
                  height: innerSize * 0.45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // ۳. محتوای مرکز (آیکون یا فضای خالی)
              Center(
                child: highlight
                    ? Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: size * 0.45,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    )
                  ],
                )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    // 🟢 محصور کردن کل ساختار در یک SizedBox با سایز قطعی جهت جلوگیری از به هم ریختن لایوت بورد
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: (highlight && centralController != null)
            ? AnimatedBuilder(
          animation: centralController,
          builder: (context, _) {
            // خرد کردن تایمر ۱۰ ثانیه‌ای به پالس‌های حرکتی ۱.۱ ثانیه‌ای
            final double cycle = (centralController.value * 10) / 1.1;
            final double progress = cycle - cycle.floor();
            final double pingPongValue = (progress - 0.5).abs() * 2;

            final double currentGlow = 0.3 + (pingPongValue * 0.7);
            final double currentBounce = -6 * pingPongValue;

            return buildTokenBody(bounce: currentBounce, glow: currentGlow);
          },
        )
            : buildTokenBody(bounce: 0.0, glow: 0.0),
      ),
    );
  }
}