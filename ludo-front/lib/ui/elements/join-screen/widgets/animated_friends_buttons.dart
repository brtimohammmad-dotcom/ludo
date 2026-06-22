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
  bool _isVisible = false;

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
      _isVisible = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFriendsButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show != oldWidget.show) {
      if (widget.show) {
        setState(() => _isVisible = true);
        _controller.forward(from: 0);
      } else {
        _controller.reverse().then((_) {
          if (mounted) setState(() => _isVisible = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

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
          ),
          const SizedBox(width: 10),
          StartGameButton(
            numberOfPlayers: -4,
            onPressed: widget.onPlay4Players,
          ),
        ],
      ),
    );
  }
}