import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatefulWidget {
  final Token token;
  final double size;
  final GameController gameController;

  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    required this.gameController,
  });

  @override
  State<TokenWidget> createState() => _TokenWidgetState();
}

class _TokenWidgetState extends State<TokenWidget>
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
    final GameState gameState = widget.gameController.gameState!;

    final tokenIsActive = TokenRules.canActiveToken(widget.token, gameState);

    final isCurrentTurn =
        gameState.serverState!.currentTurn == gameState.livePlayer!.color;

    final highlight = isCurrentTurn && tokenIsActive;

    void onTap() {
      if (highlight) {
        widget.gameController.moveToken(widget.token);
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
                        color: Colors.white.withValues(alpha: glow),
                        blurRadius: 12 + glow * 16,
                        spreadRadius: 2 + glow * 4,
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
