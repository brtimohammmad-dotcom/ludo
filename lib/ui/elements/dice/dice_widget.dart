import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
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
    ServerState state = gameController.gameState!.serverState;
    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      left: dicePath[state.currentTurn.index].dy * cellSize + (cellSize / 4),
      top: dicePath[state.currentTurn.index].dx * cellSize + (cellSize / 4),
      child: GestureDetector(
        onTap: () {
          gameController.rollDice();
        },
        child:state.turnStatus==TurnStatus.requestInFlight? Lottie.asset(
          "assets/lotties/Dice Rolling.json",
          width: cellSize *1.5,
          height: cellSize * 1.5,
          fit: BoxFit.cover,
        ): AnimatedContainer(
          padding: EdgeInsets.all(
            gameController.isMyTurnToRoll() ? cellSize / 8 : cellSize / 5,
          ),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          width: cellSize * (1.5),
          height: cellSize * (1.5),
          decoration: BoxDecoration(
            boxShadow: gameController.isMyTurnToRoll()
                ? [
                    BoxShadow(
                      color: Colors.white.withAlpha(100),
                      blurRadius: cellSize * 0.3,
                      spreadRadius: cellSize * 0.02,
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
          child:Image.asset(
                  'assets/images/dice/${gameController.gameState!.serverState.lastDiceValue}.png',
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
