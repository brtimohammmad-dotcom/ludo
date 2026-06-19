import 'package:flutter/material.dart';

class DiceWidgetMapper extends StatefulWidget {
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
  State<DiceWidgetMapper> createState() => _DiceWidgetMapperState();
}

class _DiceWidgetMapperState extends State<DiceWidgetMapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isMyTurn) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant DiceWidgetMapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isMyTurn && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }

    if (!widget.isMyTurn && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final glow = widget.isMyTurn
            ? 0.3 + (_controller.value * 0.7)
            : 0.0;

        final bounce = widget.isMyTurn
            ? -6 * _controller.value
            : 0.0;

        return Transform.translate(
          offset: Offset(0, bounce),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.size * .18,
              ),
              boxShadow: [
                if (widget.isMyTurn)
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
        size: Size.square(widget.size),
        painter: PremiumDicePainter(widget.value),
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