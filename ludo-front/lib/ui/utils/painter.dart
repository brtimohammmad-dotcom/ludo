import 'package:flutter/material.dart';

class LudoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // رنگ پس‌زمینه فلت مدرن و سبک بدون گرادینت سنگین
    final paintBg = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(rect, paintBg);

    // هاله‌های بسیار ساده و تخت بدون محاسبات پیچیده
    final paintGlow = Paint()..color = const Color(0x05FBBF24); // زرد بسیار شفاف
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), size.width * 0.3, paintGlow);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), size.width * 0.3, paintGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}