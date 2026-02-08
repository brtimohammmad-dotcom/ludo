import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ludo/domain/model/dice.dart';

class DiceController {
  final ValueNotifier<Dice> diceValue = ValueNotifier(const Dice(value: 1));
  bool diceRolled = false;
  bool isRolling = false;
  bool extraMove = false;


  Future<void> rollDice() async {
    if (diceRolled || isRolling) return;

    isRolling = true;
    int newValue = Random().nextInt(6) + 1;

    diceValue.value = Dice(value: newValue);
    diceRolled = true;
    extraMove = newValue == 6;

    await Future.delayed(const Duration(milliseconds: 500));
    isRolling = false;
  }
  void resetForNextTurn() {
    diceRolled = false;
    extraMove = false;
  }
}
