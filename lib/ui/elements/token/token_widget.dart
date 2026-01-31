import 'package:flutter/material.dart';
import 'package:ludo/controller/player_activation_controller.dart';
import 'package:ludo/controller/tokens_controller/move_token_function.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final double size;
  final TokensController controller;
  final PlayerActivationController isActiveController;
  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    required this.controller,
    required this.isActiveController
  });

  @override
  Widget build(BuildContext context) {
    int steps = 3;
    return ValueListenableBuilder(
      valueListenable: isActiveController.isActiveNotifier,
      builder: (context, isActive, _) {
        return GestureDetector(
          onTap: () {
            moveTokenSafely(
              tokenId: token.id,
              isInHome: token.isInHome,
              pathIndex: token.pathIndex,
              player: token.player,
              steps: steps,
              tokenNotifier: controller,
            );
          },
          child: SizedBox(
            width: size,
            height: size,
            child: Padding(
              padding: const EdgeInsets.all(7.0),
              child: AnimatedScale(
                curve: Curves.bounceInOut,
                duration: Duration(seconds: 1),
                scale: !isActive ? 1 : 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: tokenGradient(token),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(200),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
