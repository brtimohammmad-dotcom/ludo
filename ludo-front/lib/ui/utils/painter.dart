import 'package:flutter/material.dart';

class LudoBackgroundPainter extends CustomPainter {
  // ذخیره ذرات به صورت ثابت تا در هر بار فراخوانی متد paint دوباره محاسبه نشوند
  static final List<_Particle> _staticParticles = _generateStaticParticles(25);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ۱. ایجاد گرادینت عمیق پس‌زمینه (کاملاً بهینه)
    final bgGradient = const RadialGradient(
      center: Alignment.center,
      radius: 1.2,
      colors: [
        Color(0xFF1E293B), // هسته روشن‌تر
        Color(0xFF0F172A), // بدنه اصلی
        Color(0xFF020617), // لبه‌ها
      ],
    );

    final paintBg = Paint()..shader = bgGradient.createShader(rect);
    canvas.drawRect(rect, paintBg);

    // ۲. رسم هاله‌های نوری نئونی با استفاده از RadialGradient به جای MaskFilter.blur (افزایش چشمگیر پرفورمنس)
    _drawGlow(canvas, Offset(size.width * 0.1, size.height * 0.2), size.width * 0.4, Colors.amber);
    _drawGlow(canvas, Offset(size.width * 0.9, size.height * 0.8), size.width * 0.4, Colors.amber);

    // ۳. رسم ذرات معلق بدون تولید محاسبات تصادفی در زمان رندر
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final particle in _staticParticles) {
      // نگاشت موقعیت نسبی ذرات به ابعاد واقعی صفحه
      final x = particle.relativeX * size.width;
      final y = particle.relativeY * size.height;

      particlePaint.color = particle.color;
      canvas.drawCircle(Offset(x, y), particle.radius, particlePaint);
    }
  }

  // متد کمکی برای رسم هاله نوری فوق‌العاده سریع با گرادینت
  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    final glowGradient = RadialGradient(
      colors: [
        color.withValues(alpha: 0.05), // مرکز هاله
        color.withValues(alpha: 0.0),  // محو شدن کامل در لبه‌ها
      ],
    );

    final paint = Paint()
      ..shader = glowGradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  // تولید یک‌باره موقعیت نسبی ذرات
  static List<_Particle> _generateStaticParticles(int count) {
    // استفاده از یک سید ثابت برای حفظ موقعیت ذرات
    final random = JavaRandomLike(42);
    return List.generate(count, (_) {
      final isAmber = random.nextDouble() > 0.5;
      final alpha = random.nextDouble() * 0.25 + 0.05;

      return _Particle(
        relativeX: random.nextDouble(),
        relativeY: random.nextDouble(),
        radius: random.nextDouble() * 3 + 1,
        color: isAmber
            ? Colors.amberAccent.withValues(alpha: alpha)
            : Colors.lightGreenAccent.withValues(alpha: alpha),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// کلاس کمکی برای نگهداری اطلاعات ذرات
class _Particle {
  final double relativeX;
  final double relativeY;
  final double radius;
  final Color color;

  _Particle({
    required this.relativeX,
    required this.relativeY,
    required this.radius,
    required this.color,
  });
}

// یک پیاده‌سازی ساده برای رندومایزر دستی سبک جهت استفاده در فیلد استاتیک
class JavaRandomLike {
  int seed;
  JavaRandomLike(this.seed);
  double nextDouble() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 0x7fffffff;
  }
}