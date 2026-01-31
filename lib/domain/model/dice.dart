import 'dart:math';

import 'package:ludo/controller/tokens_controller/tokens_controller.dart';

class Dice {
  final int random;
  int newIndex = 0;
  int diceIndex;

  Dice({required this.random, required this.diceIndex});

  Dice roll(TokensController tokensController) {
    newIndex = Random().nextInt(6) + 1;
    moveNext();
    return Dice(random: newIndex, diceIndex: diceIndex);
  }

  void moveNext() {
    if (diceIndex == 3) {
      diceIndex = 0;
    } else {
      diceIndex++;
    }
  }
}
