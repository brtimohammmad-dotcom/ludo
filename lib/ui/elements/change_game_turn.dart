import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/game/game_logic.dart';

void changeGameTurn({required GameLogic gameLogic,required DiceController diceController}){
  gameLogic.currentPlayerChanger();
  diceController.diceValue.value = diceController.diceValue.value
      .changeCurrentPlayerActiveNumber(gameLogic.currentPlayerActiveNumber);
  diceController.diceValue.value.diceRolled = false;
}