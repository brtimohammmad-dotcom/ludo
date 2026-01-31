import 'package:flutter/material.dart';
import 'package:ludo/controller/tokens_controller/tokens_controller.dart';
import 'package:ludo/domain/model/dice.dart';

class DiceController {
  final TokensController tokensController;
  late final ValueNotifier<Dice> diceValue;

  DiceController({required this.tokensController}) {
    diceValue = ValueNotifier(Dice(random: 1, diceIndex: 0));
  }

  bool isRolling = false;

  Future<void> rollDice() async {
    if (isRolling) return;
    isRolling = true;
    diceValue.value.roll(tokensController);
    await Future.delayed(Duration(milliseconds: 500));

    isRolling = false;
  }
}
