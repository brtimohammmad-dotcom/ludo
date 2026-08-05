import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/logic/token-logic/token_logic.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<double> _moveAnimation;

  List<Offset> _pathPoints = const [];
  int? _prevPathIndex;

  bool get _isInterpolating => _pathPoints.length > 1;

  @override
  void initState() {
    super.initState();

    _moveController = AnimationController(vsync: this);

    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.linear,
    );

    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _pathPoints = const []);
        }
      }
    });

    _prevPathIndex = widget.token.pathIndex;
  }

  @override
  void didUpdateWidget(TokenAnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPathIndex = widget.token.pathIndex;
    if (newPathIndex != _prevPathIndex) {
      _startMove(_prevPathIndex ?? newPathIndex, newPathIndex);
    }
    _prevPathIndex = newPathIndex;
  }

  void _startMove(int from, int to) {
    // خروج از بیس (-1) یا حرکت معکوس -> اسلاید خطی ساده
    if (from == -1 || to <= from) {
      setState(() => _pathPoints = const []);
      return;
    }

    final map = movementPaths[widget.token.playerColor.index];
    if (map == null || to >= map.length) {
      setState(() => _pathPoints = const []);
      return;
    }

    final points = <Offset>[];
    for (int i = from; i <= to; i++) {
      points.add(_toLeftTop(map[i]));
    }
    setState(() => _pathPoints = points);

    final stepCount = to - from;

    // ⚡ سرعت ۲ برابر (نصف زمان اولیه): 200ms پایه + 100ms به ازای هر گام
    final totalDurationMs = 200 + (stepCount * 100);

    _moveController.duration = Duration(milliseconds: totalDurationMs);
    _moveController.forward(from: 0);
  }

  Offset _toLeftTop(Offset cell) {
    return Offset(cell.dy * widget.cellSize, cell.dx * widget.cellSize);
  }

  // درون‌یابی موقعیت مکانی مهره روی مسیر
  Offset _interpolatePosition(double t) {
    final segments = _pathPoints.length - 1;
    if (segments <= 0) return Offset(widget.left, widget.top);

    final pos = (t * segments).clamp(0.0, segments.toDouble());
    final idx = pos.floor().clamp(0, segments - 1);
    final frac = pos - idx;
    return Offset.lerp(_pathPoints[idx], _pathPoints[idx + 1], frac)!;
  }

  // درون‌یابی بزرگ/کوچک شدن مهره روی هر خانه
  double _interpolateScale(double t) {
    final stepCount = _pathPoints.length - 1;
    if (stepCount <= 0) return 1.0;

    final stepProgress = (t * stepCount) % 1.0;

    final scaleBounce = Curves.easeInOut.transform(
      (stepProgress < 0.5 ? stepProgress * 2 : (1.0 - stepProgress) * 2),
    );

    return 1.0 + (scaleBounce * 0.35); // اوج انیمیشن بزرگ‌نمایی: 1.35
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInterpolating) {
      return AnimatedBuilder(
        animation: _moveAnimation,
        builder: (context, child) {
          final t = _moveAnimation.value;
          final position = _interpolatePosition(t);
          final scale = _interpolateScale(t);

          return Positioned(
            left: position.dx,
            top: position.dy,
            child: Transform.scale(
              scale: scale,
              child: TokenWidget(
                token: widget.token,
                size: widget.cellSize,
              ),
            ),
          );
        },
      );
    }

    // حالت عادی یا جابه‌جایی مستقیم (مثل خروج از بیس)
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      left: widget.left,
      top: widget.top,
      child: TokenWidget(
        token: widget.token,
        size: widget.cellSize,
      ),
    );
  }
}