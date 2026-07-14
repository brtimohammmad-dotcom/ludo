import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/screens/board/elements/token/token_widget.dart';

class TokenAnimatedWidget extends StatefulWidget {
  final Token token;
  final double cellSize;
  final double left;
  final double top;

  const TokenAnimatedWidget({
    super.key,
    required this.token,
    required this.cellSize,
    required this.left,
    required this.top,
  });

  @override
  State<TokenAnimatedWidget> createState() => _TokenAnimatedWidgetState();
}

class _TokenAnimatedWidgetState extends State<TokenAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;



  @override
  void initState() {
    super.initState();


    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // scale: 1.0 → 1.3 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_scaleController);
  }

  @override
  void didUpdateWidget(TokenAnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // اگه position عوض شد → انیمیشن scale رو اجرا کن
    final positionChanged =
        oldWidget.left != widget.left || oldWidget.top != widget.top;

    if (positionChanged) {

      _scaleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      left: widget.left,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, cachedTokenWidget) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: cachedTokenWidget, // 👈 اینجا به جای ساخت مجدد، از کش استفاده میکند
          );
        },
        child: TokenWidget( // 👈 این بخش فقط یک بار ساخته می‌شود و حین انیمیشن فقط اسکیل می‌شود
          token: widget.token,
          size: widget.cellSize,
        ),
      ),
    );
  }
}