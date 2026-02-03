import 'package:flutter/material.dart';
import 'package:ludo/domain/model/dice.dart';

class DiceController {
  late final ValueNotifier<Dice> diceValue;
  int currentDiceIndex=1;

  DiceController() {
    diceValue = ValueNotifier(Dice(random: 1, diceIndex: currentDiceIndex));
  }

  bool isRolling = false;

  Future<void> rollDice({required DiceController controller}) async {
    if (!isRolling) {
      Dice newDice = controller.diceValue.value;
      Dice changedDice;
      isRolling = true;
      changedDice = newDice.roll();
      controller.diceValue.value = changedDice;
      await Future.delayed(Duration(milliseconds: 500));
      isRolling = false;
    }
  }
}
