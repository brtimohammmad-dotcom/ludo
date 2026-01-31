import 'package:flutter/material.dart';
import 'package:ludo/controller/dice_controller.dart';
import 'package:ludo/controller/player_activation_controller.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';

class DiceWidget extends StatelessWidget {
  final DiceController diceController;
  final double cellSize;
  final PlayerActivationController isActiveController;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceController,
    required this.isActiveController
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: diceController.diceValue,
      builder: (context, controller, _) {
        return AnimatedPositioned(
          curve: Curves.easeOutQuad,
          duration: Duration(milliseconds: 500),
          left: dicePath[controller.diceIndex].dy * cellSize,
          top: dicePath[controller.diceIndex].dx * cellSize,
          child: GestureDetector(
            onTap: () {
              diceController.rollDice();
              if(controller.random==6){
                isActiveController.activeToken();
              }
            },
            child: Container(
              color: Colors.white,
              width: cellSize * 2,
              height: cellSize * 2,
              child: Center(
                child: Text(
                  ('${controller.random}'),
                  style: TextStyle(color: Colors.black, fontSize: 50),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
