import 'package:flutter/material.dart';

class BoardBackground extends StatelessWidget {
  const BoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: RepaintBoundary(
          child: CustomPaint(
            painter: LudoOptimizedPainter(),
          ),
        ),
      ),
    );
  }
}

class LudoOptimizedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double step = size.width / 11; // ابعاد ماتریس ۱۱ در ۱۱ شما

    const Color baseBgColor = Color(0xffD5B195);
    const Color borderColor = Colors.black12;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // ۱. رسم بک‌گراند کلی خانه‌های عادی مسیر با رنگ کرم مبنا
    final Paint defaultCellPaint = Paint()..color = baseBgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), defaultCellPaint);

    // ۲. رسم خانه‌های مسیر ۱۱ در ۱۱ با افکت شعاعی زیبا
    for (int r = 0; r < 11; r++) {
      for (int c = 0; c < 11; c++) {
        if ((r < 4 && c < 4) || (r < 4 && c > 6) ||
            (r > 6 && c < 4) || (r > 6 && c > 6) ||
            (r >= 4 && r <= 6 && c >= 4 && c <= 6)) {
          continue;
        }

        final Rect cellRect = Rect.fromLTWH(c * step, r * step, step, step);

        if (r > 6 && c == 5 || r == 10 && c == 4) {
          _drawRadialCell(canvas, cellRect, [Colors.red.shade400, Colors.red.shade700]);
        } else if (r == 5 && c > 6 || r == 6 && c == 10) {
          _drawRadialCell(canvas, cellRect, [Colors.green.shade400, Colors.green.shade700]);
        } else if (r == 5 && c < 4 || r == 4 && c == 0) {
          _drawRadialCell(canvas, cellRect, [Colors.blue.shade400, Colors.blue.shade700]);
        } else if (r < 4 && c == 5 || r == 0 && c == 6) {
          _drawRadialCell(canvas, cellRect, [Colors.yellow.shade400, Colors.yellow.shade600]);
        } else {
          _drawRadialCell(canvas, cellRect, [baseBgColor.withAlpha(220), baseBgColor]);
        }

        canvas.drawRect(cellRect, borderPaint);
      }
    }

    // ۳. رسم بیس‌های بزرگ گوشه (کاملاً مربع و چهارگوش - بدون لبه گرد)
    _drawBaseHome(canvas, Rect.fromLTWH(0, 0, step * 4, step * 4), [Colors.blueAccent, Colors.blue.shade700], step);
    _drawBaseHome(canvas, Rect.fromLTWH(step * 7, 0, step * 4, step * 4), [Colors.yellowAccent.shade100, Colors.yellow.shade600], step);
    _drawBaseHome(canvas, Rect.fromLTWH(0, step * 7, step * 4, step * 4), [Colors.redAccent, Colors.red.shade700], step);
    _drawBaseHome(canvas, Rect.fromLTWH(step * 7, step * 7, step * 4, step * 4), [Colors.greenAccent.shade400, Colors.green.shade700], step);

    // ۴. رسم مثلث‌های متلاقی در مرکز بازی (محدوده ۴ تا ۶)
    final double cStart = step * 4;
    final double cEnd = step * 7;
    final Offset center = Offset(size.width / 2, size.height / 2);

    _drawTriangle(canvas, [Colors.yellow.shade400, Colors.yellow.shade600], Offset(cStart, cStart), Offset(cEnd, cStart), center);
    _drawTriangle(canvas, [Colors.green.shade400, Colors.green.shade600], Offset(cEnd, cStart), Offset(cEnd, cEnd), center);
    _drawTriangle(canvas, [Colors.red.shade400, Colors.red.shade600], Offset(cStart, cEnd), Offset(cEnd, cEnd), center);
    _drawTriangle(canvas, [Colors.blue.shade400, Colors.blue.shade600], Offset(cStart, cStart), Offset(cStart, cEnd), center);

    // رسم خطوط مرزی وسط
    canvas.drawPath(Path()..moveTo(cStart, cStart)..lineTo(cEnd, cEnd), borderPaint);
    canvas.drawPath(Path()..moveTo(cEnd, cStart)..lineTo(cStart, cEnd), borderPaint);
    canvas.drawRect(Rect.fromLTWH(cStart, cStart, step * 3, step * 3), borderPaint);
  }

  void _drawRadialCell(Canvas canvas, Rect rect, List<Color> colors) {
    final paint = Paint()
      ..shader = RadialGradient(colors: colors, radius: 0.7).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawBaseHome(Canvas canvas, Rect rect, List<Color> colors, double cellSize) {
    // 🟢 تغییر به drawRect برای داشتن لبه‌های کاملاً تیز و مربعی در بیس‌های بزرگ گوشه
    final Paint basePaint = Paint()
      ..shader = RadialGradient(colors: colors, radius: 0.8).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // رسم کانتینر داخلی شفاف (محل دایره مهره‌ها) با حاشیه سفید محو و لبه گرد (مانند تصویر شما)
    final double margin = cellSize / 2.5;
    final Rect innerRect = rect.deflate(margin);
    final Paint innerPaint = Paint()
      ..color = const Color(0xffD5B195).withAlpha(45);

    canvas.drawRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize / 2)), innerPaint);
  }

  void _drawTriangle(Canvas canvas, List<Color> colors, Offset p1, Offset p2, Offset p3) {
    final Rect bounds = Rect.fromPoints(p1, p2);
    final paint = Paint()
      ..shader = LinearGradient(colors: colors, begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(bounds)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}