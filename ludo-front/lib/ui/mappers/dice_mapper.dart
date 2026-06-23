import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class DiceWidgetMapper extends ConsumerWidget {
  final int value;
  final double size;
  final bool isMyTurn;

  const DiceWidgetMapper({
    super.key,
    required this.value,
    required this.isMyTurn,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameControllerProvider.notifier);
    final centralController = gameController.animationController;

    // 🟢 اگر نوبت ما نیست یا کنترلر مرکزی نال است، بدون انیمیشن رندر شود
    if (!isMyTurn || centralController == null) {
      return CustomPaint(
        size: Size.square(size),
        painter: PremiumDicePainter(value),
      );
    }

    // 🟢 استفاده از انیمیشن مرکزی برای شبیه‌سازی انیمیشن تکرارشونده ۱.۲ ثانیه‌ای
    return AnimatedBuilder(
      animation: centralController,
      builder: (_, child) {
        // زمان کل کنترلر مرکزی ۱۰ ثانیه است. می‌خواهیم انیمیشن هر ۱.۲ ثانیه تکرار شود (فرکانس مناسب)
        // با این فرمول یک موج سینوسی روان بین ۰ تا ۱ ایجاد می‌کنیم که ربطی به جلو رفتن کل تایمر ندارد
        final double centralValue = centralController.value;
        final double cycle = (centralValue * 10) / 1.2; // چند سیکل طی شده
        final double animationProgress = (cycle - cycle.floor()); // مقدار باقیمانده بین 0.0 تا 1.0

        // شبیه‌سازی حرکت reverse (رفت و برگشت) با تبدیل قدرمطلق ریاضی
        final double pingPongValue = (animationProgress - 0.5).abs() * 2;

        final glow = 0.3 + (pingPongValue * 0.7);
        final bounce = -6 * pingPongValue;

        return Transform.translate(
          offset: Offset(0, bounce),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .18),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: glow),
                  blurRadius: 12 + glow * 14,
                  spreadRadius: 2 + glow * 4,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: CustomPaint(
        size: Size.square(size),
        painter: PremiumDicePainter(value),
      ),
    );
  }
}
class PremiumDicePainter extends CustomPainter {
  final int value;

  PremiumDicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );

    canvas.drawShadow(
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(size.width * .18),
          ),
        ),
      Colors.black,
      8,
      true,
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.grey.shade100,
          Colors.grey.shade300,
        ],
      ).createShader(rect);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black12;

    final dice = RRect.fromRectAndRadius(
      rect.deflate(2),
      Radius.circular(size.width * .18),
    );

    canvas.drawRRect(dice, bodyPaint);
    canvas.drawRRect(dice, borderPaint);

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: .9),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height * .45,
        ),
      );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          6,
          6,
          size.width - 12,
          size.height * .35,
        ),
        Radius.circular(size.width * .14),
      ),
      shinePaint,
    );

    final dotRadius = size.width * .08;

    final tl = Offset(size.width * .25, size.height * .25);
    final tr = Offset(size.width * .75, size.height * .25);

    final ml = Offset(size.width * .25, size.height * .50);
    final mc = Offset(size.width * .50, size.height * .50);
    final mr = Offset(size.width * .75, size.height * .50);

    final bl = Offset(size.width * .25, size.height * .75);
    final br = Offset(size.width * .75, size.height * .75);

    void dot(Offset p) {
      canvas.drawCircle(
        p.translate(1.5, 2),
        dotRadius,
        Paint()..color = Colors.black26,
      );

      canvas.drawCircle(
        p,
        dotRadius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.grey.shade800,
              Colors.black,
            ],
          ).createShader(
            Rect.fromCircle(
              center: p,
              radius: dotRadius,
            ),
          ),
      );

      canvas.drawCircle(
        p.translate(
          -dotRadius * .25,
          -dotRadius * .25,
        ),
        dotRadius * .25,
        Paint()..color = Colors.white24,
      );
    }

    switch (value) {
      case 1:
        dot(mc);
        break;

      case 2:
        dot(tl);
        dot(br);
        break;

      case 3:
        dot(tl);
        dot(mc);
        dot(br);
        break;

      case 4:
        dot(tl);
        dot(tr);
        dot(bl);
        dot(br);
        break;

      case 5:
        dot(tl);
        dot(tr);
        dot(mc);
        dot(bl);
        dot(br);
        break;

      case 6:
        dot(tl);
        dot(ml);
        dot(bl);
        dot(tr);
        dot(mr);
        dot(br);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant PremiumDicePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}