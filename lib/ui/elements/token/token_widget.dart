import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/controller/tokens-controller/on_tap_token.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final double size;
  final TokensController controller;
  final DiceController diceController;
  final GameController gameController;

  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    required this.controller,
    required this.diceController,
    required this.gameController
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapToken(token: token,
          diceController: diceController,
          controller: controller,
      gameController: gameController),
      child: SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: tokenGradient(token),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(200), width: 3),
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
    ),);
  }
}
