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

    // ⚡ لایه اصلی و تخت تاس (بدون سایه و گرادینت‌های سنگین در پینتر)
    final Widget staticDiceCanvas = CustomPaint(
      size: Size.square(size),
      painter: PremiumDicePainter(value),
    );

    // اگر نوبت ما نیست یا کنترلر مرکزی نال است، مستقیماً لایه تخت رندر شود
    if (!isMyTurn || centralController == null) {
      return staticDiceCanvas;
    }

    // 🟢 استفاده از انیمیشن مرکزی برای شبیه‌سازی پالس با افکت Scale برداری (فوق‌العاده چابک و بدون لگ)
    return AnimatedBuilder(
      animation: centralController,
      child: staticDiceCanvas, // پاس دادن تاس به عنوان child ثابت تا پینتر دوباره اجرا نشود
      builder: (_, child) {
        final double centralValue = centralController.value;
        final double cycle = (centralValue * 10) / 1.2;
        final double animationProgress = (cycle - cycle.floor());

        final double pingPongValue = (animationProgress - 0.5).abs() * 2;

        // ایجاد یک پالس اندازه تخت و بدون سایه چشمی
        final double pulseScale = 1.0 + (pingPongValue * 0.08);

        return Transform.scale(
          scale: pulseScale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .18),
              // یک بوردر زرد نئون تخت، شیک و کاملاً Solid بجای سایه متحرک سفید
              border: Border.all(
                color:  Colors.white,
                width: 2.0,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class PremiumDicePainter extends CustomPainter {
  final int value;

  PremiumDicePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);


    final bodyPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF8F9FA);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0x26000000);

    final dice = RRect.fromRectAndRadius(
      rect.deflate(1),
      Radius.circular(size.width * .18),
    );

    canvas.drawRRect(dice, bodyPaint);
    canvas.drawRRect(dice, borderPaint);


    final dotRadius = size.width * .08;

    // موقعیت‌های استاندارد نقطه‌های تاس روی بورد
    final tl = Offset(size.width * .25, size.height * .25);
    final tr = Offset(size.width * .75, size.height * .25);

    final ml = Offset(size.width * .25, size.height * .50);
    final mc = Offset(size.width * .50, size.height * .50);
    final mr = Offset(size.width * .75, size.height * .50);

    final bl = Offset(size.width * .25, size.height * .75);
    final br = Offset(size.width * .75, size.height * .75);

    void dot(Offset p) {
      // فقط یک دایره مشکی تخت با لبه‌های بسیار تمیز و برداری
      canvas.drawCircle(
        p,
        dotRadius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF1A1A1A), // مشکی ذغالی تخت
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