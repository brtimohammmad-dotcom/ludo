import 'package:flutter/material.dart';

class LudoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ۱. پس‌زمینه اصلی با رنگ چوب گردوی تیره برای عمق دادن به صفحه
    final bgPaint = Paint()..color = const Color(0xFF1E120B);
    canvas.drawRect(rect, bgPaint);

    // ۲. قوس نرم بالا با رنگ چوب ماهگونی روشن‌تر (مخصوص بخش هدر و سکه‌ها)
    final topShapePath = Path();
    topShapePath.lineTo(0, size.height * 0.18);
    topShapePath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.24,
      size.width,
      size.height * 0.18,
    );
    topShapePath.lineTo(size.width, 0);
    topShapePath.close();

    final topShapePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4A2A18), Color(0xFF381F12)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawPath(topShapePath, topShapePaint);

    // ۳. قوس نرم پایین با رنگ چوب داغ و گرم (پشت منوی شناور)
    final bottomShapePath = Path();
    bottomShapePath.moveTo(0, size.height * 0.82);
    bottomShapePath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.76,
      size.width,
      size.height * 0.82,
    );
    bottomShapePath.lineTo(size.width, size.height);
    bottomShapePath.lineTo(0, size.height);
    bottomShapePath.close();

    final bottomShapePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF381F12), Color(0xFF2A160C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawPath(bottomShapePath, bottomShapePaint);

    // ۴. تخته چوبی وسط (محل قرارگیری کارت‌ها و لیست لول‌ها)
    final woodBoardRect = RRect.fromLTRBR(
      size.width * 0.04,
      size.height * 0.20,
      size.width * 0.96,
      size.height * 0.80,
      const Radius.circular(24),
    );

    // گرادیان رنگ چوب بلوط روشن برای بدنه‌ اصلی
    final woodBoardPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8B5A2B), // چوب دارچینی/بلوط
          Color(0xFF6F431A), // چوب کهنسال
          Color(0xFF5C3613),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(woodBoardRect.outerRect);

    canvas.drawRRect(woodBoardRect, woodBoardPaint);

    // ۵. سایه و لبه برجسته چوبی (Wood Border Shadow)
    final borderPaint = Paint()
      ..color = const Color(0xFF3D210F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawRRect(woodBoardRect, borderPaint);

    // ۶. شیارهای افقی چوب (Wood Planks) برای واقعی‌تر شدن حس چوب
    final plankPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.5;

    final double plankSpacing = size.height * 0.06;
    for (double y = size.height * 0.22; y < size.height * 0.78; y += plankSpacing) {
      canvas.drawLine(
        Offset(size.width * 0.06, y),
        Offset(size.width * 0.94, y),
        plankPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}