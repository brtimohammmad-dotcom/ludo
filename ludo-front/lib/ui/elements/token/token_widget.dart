import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends ConsumerStatefulWidget {
  final Token token;
  final double size;

  const TokenWidget({super.key, required this.token, required this.size});

  @override
  ConsumerState<TokenWidget> createState() => _TokenWidgetState();
}

class _TokenWidgetState extends ConsumerState<TokenWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool highlight = ref.watch(
      gameControllerProvider.select(
        (state) => state.canTokenMove(widget.token),
      ),
    );
    final bool tokenIsActive = ref.watch(
      gameControllerProvider.select(
        (state) => state.canActiveToken(widget.token),
      ),
    );

    void onTap() {
      if (highlight) {
        ref.read(gameControllerProvider.notifier).moveToken(widget.token);
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            final glow = highlight ? 0.3 + (_controller.value * 0.7) : 0.0;

            final bounce = highlight ? -6 * _controller.value : 0.0;

            return Transform.translate(
              offset: Offset(0, bounce),
              child: Container(
                margin: EdgeInsets.all(
                  tokenIsActive ? widget.size / 9 : widget.size / 5,
                ),
                decoration: BoxDecoration(
                  gradient: tokenGradient(widget.token),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(200),
                    width: widget.size / 15,
                  ),
                  boxShadow: [
                    if (highlight)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: glow),
                        blurRadius: 12 + glow * 16,
                        spreadRadius: 2 + glow * 4,
                      )
                    else if (tokenIsActive)
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    else
                      const BoxShadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(-2, 3),
                      ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: highlight
              ? Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white,
                  size: widget.size * 0.45,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
