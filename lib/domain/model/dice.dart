import 'dart:math';

class Dice {
  final int random;

  final int diceIndex;

  Dice({required this.random, required this.diceIndex});

  Dice roll() {
    int newDiceValue;
    newDiceValue = Random().nextInt(6) + 1;
   return dicePicker(newDiceValue);
  }

  Dice dicePicker(int newDiceValue) {
    if (diceIndex == 4) {
      return Dice(random: newDiceValue, diceIndex: 1);
    } else {
      return Dice(random: newDiceValue, diceIndex: diceIndex + 1);
    }
  }
}
