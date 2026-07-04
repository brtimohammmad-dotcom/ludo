import 'package:flutter/material.dart';
import 'start_game_button.dart';

class AnimatedFriendsButtons extends StatefulWidget {
  final double boardSize;
  final bool show;
  final VoidCallback onPlay2Players;
  final VoidCallback onPlay4Players;

  const AnimatedFriendsButtons({
    super.key,
    required this.show,
    required this.boardSize,
    required this.onPlay2Players,
    required this.onPlay4Players,
  });

  @override
  State<AnimatedFriendsButtons> createState() => _AnimatedFriendsButtonsState();
}

class _AnimatedFriendsButtonsState extends State<AnimatedFriendsButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideDownAnimation;
  late final Animation<Offset> _settleUpAnimation;

  // استفاده از ValueNotifier به جای متغیر معمولی و setState
  final ValueNotifier<bool> _isVisibleNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    );

    _slideDownAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _settleUpAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.15),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.show) {
      _isVisibleNotifier.value = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFriendsButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        _isVisibleNotifier.value = true; // تغییر مقدار بدون setState
        _controller.forward(from: 0);
      } else {
        _controller.reverse().then((_) {
          if (mounted) _isVisibleNotifier.value = false; // تغییر مقدار بدون setState
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isVisibleNotifier.dispose(); // دیسپوز کردن ناظر برای جلوگیری از لیک
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // فقط بخش مربوط به حضور یا عدم حضور ویجت به این واچر گوش می‌دهد
    return ValueListenableBuilder<bool>(
      valueListenable: _isVisibleNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final combinedOffset = Offset(
              0,
              _slideDownAnimation.value.dy + _settleUpAnimation.value.dy,
            );
            return Opacity(
              opacity: _fadeAnimation.value,
              child: FractionalTranslation(
                translation: combinedOffset,
                child: child,
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StartGameButton(
                numberOfPlayers: -2,
                onPressed: widget.onPlay2Players,
                  boardSize:widget.boardSize

              ),
               SizedBox(width:widget.boardSize*0.01 ),
              StartGameButton(
                numberOfPlayers: -4,
                onPressed: widget.onPlay4Players,
                  boardSize:widget.boardSize

              ),
            ],
          ),
        );
      },
    );
  }
}