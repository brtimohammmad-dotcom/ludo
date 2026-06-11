// token_animated_widget.dart
import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/elements/token/token_widget.dart';

class TokenAnimatedWidget extends StatefulWidget {
  final Token token;
  final double cellSize;
  final double left;
  final double top;
  final GameController gameController;

  const TokenAnimatedWidget({
    super.key,
    required this.token,
    required this.cellSize,
    required this.left,
    required this.top,
    required this.gameController,
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
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: TokenWidget(
          token: widget.token,
          gameController: widget.gameController,
          size: widget.cellSize,
        ),
      ),
    );
  }
}