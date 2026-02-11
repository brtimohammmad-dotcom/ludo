import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final double size;
  final TokensController controller;
  final GameController gameController;

  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    required this.controller,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    Token newToken = controller.tokenNotifier.value.firstWhere((otherToken) {
      return otherToken.id == token.id;
    });
    bool isActiveToken = newToken.isActive;
    return GestureDetector(
      onTap: () {
        gameController.onTapToken(token: newToken);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: AnimatedContainer(
          curve: Curves.easeOut,
          margin: EdgeInsets.all(isActiveToken ? 5.0 : 7.0),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: tokenGradient(token),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(200), width: 3),
            boxShadow: isActiveToken
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
