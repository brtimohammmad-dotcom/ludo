import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    bool tokenIsActive = gameController.canActiveToken(token);
    return GestureDetector(
      onTap: () {
        gameController.moveToken(token);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedContainer(
          curve: Curves.easeOut,
          margin: EdgeInsets.all(tokenIsActive ? size / 9 : size / 5),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: tokenGradient(token),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withAlpha(200),
              width: size / 15,
            ),
            boxShadow: tokenIsActive
                ? activeTokenShadow(token)
                : [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: Offset(-2, 3),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
