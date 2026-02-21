import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';

class DiceWidget extends StatelessWidget {
  final double cellSize;
  final GameController gameController;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMyTurnToRoll =
        gameController.gameState!.serverState.currentTurn ==
        gameController.gameState!.clientState.livePlayer.color;
    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      left:
          dicePath[gameController.gameState!.serverState.currentTurn.index].dy *
              cellSize +
          (cellSize / 4),
      top:
          dicePath[gameController.gameState!.serverState.currentTurn.index].dx *
              cellSize +
          (cellSize / 4),
      child: GestureDetector(
        onTap: () {
          gameController.rollDice();
        },
        child: AnimatedContainer(
          padding: EdgeInsets.all(isMyTurnToRoll ? cellSize/8 : cellSize/6),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          width: cellSize * (1.5),
          height: cellSize * (1.5),
          decoration: BoxDecoration(
            boxShadow: isMyTurnToRoll
                ? [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(-2, 3),
                      spreadRadius: -10,
                    ),
                  ],
          ),
          child: Image.asset(
            'assets/images/dice/${gameController.gameState!.serverState.lastDiceValue}.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
