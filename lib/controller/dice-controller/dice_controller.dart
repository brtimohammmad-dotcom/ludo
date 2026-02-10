import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_tap_lock.dart';
import 'package:ludo/domain/model/dice.dart';

class DiceController {
  final ValueNotifier<Dice> diceValue = ValueNotifier(const Dice(value: 1));
  bool isRolling = false;
  bool extraMove = false;

  Future<void> rollDice() async {
    if (isRolling) return;

    isRolling = true;
    int newValue = Random().nextInt(6) + 1;

    diceValue.value = Dice(value: newValue);
    extraMove = newValue == 6;

    await Future.delayed(const Duration(milliseconds: 500));
    isRolling = false;
  }

  void resetForNextTurn() async {
    extraMove = false;
    await Future.delayed(Duration(milliseconds: 500));
    DiceTapLock.unlock();
  }
}
