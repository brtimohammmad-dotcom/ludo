import 'package:flutter/material.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/tokens_controller/move_token_function.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/game/game_logic.dart';
import 'package:ludo/ui/mappers/token_ui_mapper.dart';

class TokenWidget extends StatelessWidget {
  final Token token;
  final double size;
  final TokensController controller;
  final DiceController diceController;
  final GameLogic gameLogic;

  const TokenWidget({
    super.key,
    required this.token,
    required this.size,
    required this.controller,
    required this.diceController,
    required this.gameLogic,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (gameLogic.currentPlayerActiveNumber == token.player) {
          if ((diceController.diceValue.value.diceRolled ||
              diceController.diceValue.value.extraMove)) {
            moveTokenSafely(
              tokenNotifier: controller,
              token: token,
              diceController: diceController,
              gameLogic: gameLogic,
            );

            if (diceController.diceValue.value.extraMove &&
                diceController.diceValue.value.diceRolled) {
              diceController.diceValue.value.extraMove = false;
              diceController.diceValue.value.diceRolled = false;
            } else if (!diceController.diceValue.value.extraMove &&
                diceController.diceValue.value.diceRolled) {
              diceController.diceValue.value.diceRolled = false;
              gameLogic.currentPlayerChanger();
              diceController.changeCurrentPlayerActiveNumber(
                gameLogic.currentPlayerActiveNumber,
              );
            }
          }
        }
      },
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
      ),
    );
  }
}
