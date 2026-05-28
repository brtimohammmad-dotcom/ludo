import 'package:flutter/material.dart';

class CenterPainter extends CustomPainter {
  final int row;
  final int col;

  CenterPainter(this.row, this.col);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    //yellow painter
    if (row == 5 && col == 5) {
      _drawTriangle(
        canvas,
        size,
        Colors.yellow,
        Offset(0, 0),
        Offset(size.width, 0),
        center,
      );
    }
    if (row == 4 && col == 4) {
      _drawTriangle(
        canvas,
        size,
        Colors.yellow,
        Offset(0, 0),
        Offset(size.width, 0),
        Offset(size.width, size.height),
      );
    }
    if (row == 4 && col == 6) {
      _drawTriangle(
        canvas,
        size,
        Colors.yellow,
        Offset(0, 0),
        Offset(0, size.height),
        Offset(size.width, 0),
      );
    }
    if (row == 4 && col ==5) {
      _drawRect(canvas, Colors.yellow, size);
    }
    // green painter
    if (row == 5 && col == 5) {
      _drawTriangle(
        canvas,
        size,
        Colors.green,
        Offset(size.width, 0),
        Offset(size.width, size.height),
        center,
      );
    }
    if (row == 4 && col == 6) {
      _drawTriangle(
        canvas,
        size,
        Colors.green,
        Offset(size.width, 0),
        Offset(size.width, size.height),
        Offset(0, size.height),
      );
    }
    if (row == 6 && col == 6) {
      _drawTriangle(
        canvas,
        size,
        Colors.green,
        Offset(0, 0),
        Offset(size.width, 0),
        Offset(size.width, size.height),
      );
    }
    if (row == 5 && col == 6) {
      _drawRect(canvas, Colors.green, size);
    }
    // red painter

    if (row == 5 && col == 5) {
      _drawTriangle(
        canvas,
        size,
        Colors.red,
        Offset(size.width, size.height),
        Offset(0, size.height),
        center,
      );
    }
    if (row == 6 && col == 6) {
      _drawTriangle(
        canvas,
        size,
        Colors.red,
        Offset(size.width, size.height),
        Offset(0, size.height),
        Offset(0, 0),
      );
    }
    if (row == 6 && col == 4) {
      _drawTriangle(
        canvas,
        size,
        Colors.red,
        Offset(size.width, size.height),
        Offset(0, size.height),
        Offset(size.width, 0),
      );
    }
    if (row == 6 && col == 5) {
      _drawRect(canvas, Colors.red, size);
    }
    // blue painter
    if (row == 5 && col == 5) {
      _drawTriangle(
        canvas,
        size,
        Colors.blue,
        Offset(0, size.height),
        Offset(0, 0),
        center,
      );
    }
    if (row == 4 && col == 4) {
      _drawTriangle(
        canvas,
        size,
        Colors.blue,
        Offset(0, size.height),
        Offset(0, 0),
        Offset(size.width, size.height),
      );
    }
    if (row == 6 && col == 4) {
      _drawTriangle(
        canvas,
        size,
        Colors.blue,
        Offset(0, size.height),
        Offset(0, 0),
        Offset(size.width, 0),
      );
    }
    if (row == 5 && col == 4) {
      _drawRect(canvas, Colors.blue, size);
    }
  }

  void _drawTriangle(
      Canvas canvas,
      Size size,
      Color color,
      Offset p1,
      Offset p2,
      Offset p3,
      ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  void _drawRect(Canvas canvas, Color color, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
