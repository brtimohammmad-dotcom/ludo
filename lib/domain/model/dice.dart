import 'dart:math';

class Dice {
  final int random;
  int currentPlayerActiveNumber;
  bool diceRolled;
  bool extraMove;

  Dice({
    required this.random,
    required this.currentPlayerActiveNumber,
    required this.diceRolled,
    required this.extraMove,
  });

  Dice roll() {
    int newDiceValue;
    newDiceValue = Random().nextInt(6) + 1;
    if(newDiceValue!=6){
      return Dice(
        random: newDiceValue,
        currentPlayerActiveNumber: currentPlayerActiveNumber,
        diceRolled: true,
        extraMove: false
      );
    }else{
      return Dice(
        random: newDiceValue,
        currentPlayerActiveNumber: currentPlayerActiveNumber,
        diceRolled: true,
        extraMove: true
      );
    }

  }

  Dice changeCurrentPlayerActiveNumber(int newCurrentPlayerActiveNumber) {
    return Dice(
      random: random,
      currentPlayerActiveNumber: newCurrentPlayerActiveNumber,
      diceRolled: diceRolled,
      extraMove: false
    );
  }
}
