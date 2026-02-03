import 'dart:math';

class Dice {
  final int random;
  final int currentPlayerActiveNumber;
  bool diceRolled;

  Dice({
    required this.random,
    required this.currentPlayerActiveNumber,
    required this.diceRolled,
  });

  Dice roll() {
    int newDiceValue;
    diceRolled = true;
    newDiceValue = Random().nextInt(6) + 1;
    return Dice(
      random: newDiceValue,
      currentPlayerActiveNumber: currentPlayerActiveNumber,
      diceRolled: true,
    );
  }
}
