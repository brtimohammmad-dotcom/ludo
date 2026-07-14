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
  late final Animation<Offset> _slideAnimation;

  final ValueNotifier<bool> _isVisibleNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );


    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // جابجایی یکپارچه از بالا (-0.4) به مکان اصلی (0.0)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

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
        _isVisibleNotifier.value = true;
        _controller.forward(from: 0);
      } else {
        _controller.reverse().then((_) {
          if (mounted) {
            _isVisibleNotifier.value = false;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _isVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isVisibleNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) return const SizedBox.shrink();

        // 🟢 استفاده از ترنزیشن‌های بومی و نیتیو فلاتر بدون درگیر کردن لایه لایوت و کاملا شتاب‌یافته گرافیکی
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child, // فرزندان کاملاً ایزوله هستند و در هر فریم ریبلد نمی‌شوند
          ),
        );
      },
      // دکمه‌ها را به بخش ثابت (child) منتقل کردیم تا در طول فرآیند انیمیشن، کدهای داخلی دکمه‌ها پردازش مجدد نشوند
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StartGameButton(
            prizePool: 0,
            entryFee: 0,
            numberOfPlayers: -2,
            onPressed: widget.onPlay2Players,
            boardSize: widget.boardSize,
          ),
          SizedBox(width: widget.boardSize * 0.01),
          StartGameButton(
            entryFee: 0,
            prizePool: 0,
            numberOfPlayers: -4,
            onPressed: widget.onPlay4Players,
            boardSize: widget.boardSize,
          ),
        ],
      ),
    );
  }
}