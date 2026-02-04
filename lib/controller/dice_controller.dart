import 'package:flutter/material.dart';
import 'package:ludo/domain/model/dice.dart';

class DiceController {
  late final ValueNotifier<Dice> diceValue;

  DiceController() {
    diceValue = ValueNotifier(
      Dice(currentPlayerActiveNumber: 1, random: 1, diceRolled: false,extraMove: false),
    );
  }

  bool isRolling = false;

  void changeCurrentPlayerActiveNumber(int newCurrentPlayerActiveNumber) {
    Dice newDice = diceValue.value;
    Dice changedDice;
    changedDice = newDice.changeCurrentPlayerActiveNumber(
      newCurrentPlayerActiveNumber,
    );
    diceValue.value = changedDice;
  }

  Future<void> rollDice() async {
    if (!isRolling) {
      Dice newDice = diceValue.value;
      Dice changedDice;
      isRolling = true;
      changedDice = newDice.roll();
      diceValue.value = changedDice;
      await Future.delayed(Duration(milliseconds: 500));
      isRolling = false;
    }
  }
}
