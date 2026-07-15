import 'dart:math' as math;
import 'package:flutter/material.dart';

class LudoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ۱. ایجاد گرادینت عمیق پس‌زمینه (ترکیبی از سورمه‌ای تیره و مشکی تم دیالوگ‌ها)
    final bgGradient = const RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        Color(0xFF1E293B), // هسته روشن‌تر (سورمه‌ای تم دیالوگ‌ها)
        Color(0xFF0F172A), // بدنه اصلی
        Color(0xFF020617), // لبه‌های کاملاً تیره برای ایجاد عمق
      ],
    );

    final paintBg = Paint()..shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, paintBg);

    // ۲. رسم هاله‌های نوری نئونی در گوشه‌ها (Neon Glow)
    final amberGlowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), size.width * 0.4, amberGlowPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), size.width * 0.4, amberGlowPaint);

    // ۳. رسم ذرات معلق نئونی (Floating Tech Particles) برای ایجاد حس پویایی ثابت
    final random = math.Random(42); // Seed ثابت برای اینکه ذرات در هر فریم حرکت نکنند و پرش نداشته باشند
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1; // بین ۱ تا ۴ پیکسل
      final alpha = random.nextDouble() * 0.25 + 0.05; // شفافیت ملایم

      // ترکیب رنگی ذرات (بیشتر طلایی و کمی سبز نئونی ملایم)
      final color = random.nextBool()
          ? Colors.amberAccent.withValues(alpha: alpha)
          : Colors.lightGreenAccent.withValues(alpha: alpha);

      particlePaint.color = color;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}