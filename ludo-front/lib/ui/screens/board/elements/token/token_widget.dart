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

    // 🟢 لایه اصلی و ثابت مهره (بدون سایه و با رنگ‌های کاملاً Solid)
    final Widget staticTokenBody = Container(
      margin: EdgeInsets.all(currentMargin),
      decoration: BoxDecoration(
          boxShadow: [
             BoxShadow(
              color: Color(0x33000000),
              blurRadius: 0,
              spreadRadius: 0,
              offset: Offset(-size*0.04, size*0.07),
            ),
          ],
        gradient: tokenGradient(token),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFFFFF), // سفید ۱۰۰٪ بدون شفافیت
          width: size / 14,
        ),
      ),
      child: Stack(
        children: [
          // رفلکس نوری هلالی قطعی (بدون محو شدگی شدید)
          Positioned(
            top: innerSize * 0.05,
            left: innerSize * 0.08,
            child: Container(
              width: innerSize * 0.45,
              height: innerSize * 0.2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x40FFFFFF), // سفید ثابت با شفافیت کم برای رفلکس
              ),
            ),
          ),
          // حلقه نوری داخلی تخت
          Center(
            child: Container(
              width: innerSize * 0.45,
              height: innerSize * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x33FFFFFF),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // آیکون راهنما در مرکز
          Center(
            child: highlight
                ? Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: size * 0.45,
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
          child: staticTokenBody,
          builder: (context, child) {
            final double cycle = (centralController.value * 10) / 1.1;
            final double progress = cycle - cycle.floor();
            final double pingPongValue = (progress - 0.5).abs() * 2;

            // ⚡ به جای سایه، یک افکت رینگ نئون تخت دور مهره ایجاد می‌کنیم که بزرگ و کوچک می‌شود
            final double ringScale = 1.0 + (pingPongValue * 0.12);

            return Transform.scale(
              scale: ringScale,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: Colors.white, // رنگ زرد نئون قطعی (Solid) برای جلب توجه نوبت
                      width: 2.5,
                    ),
                  ),
                ),
                child: child,
              ),
            );
          },
        )
            : staticTokenBody, // اگر هایلایت نبود، مستقیماً و بدون هیچ کانتینر اضافه‌ای رندر می‌شود
      ),
    );
  }
}