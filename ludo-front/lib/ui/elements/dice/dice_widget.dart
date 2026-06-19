import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';
import 'package:ludo/ui/mappers/dice_mapper.dart';

class DiceWidget extends StatelessWidget {
  final double cellSize;
  final GameController gameController;
  final Future<LottieComposition> diceComposition;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.gameController,
    required this.diceComposition,
  });

  @override
  Widget build(BuildContext context) {
    ServerState state = gameController.gameState!.serverState!;
    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      left: dicePath[state.currentTurn.index].dy * cellSize + (cellSize / 4),
      top: dicePath[state.currentTurn.index].dx * cellSize + (cellSize / 4),
      child: GestureDetector(
        onTap: () {
          gameController.rollDice();
        },
        child: state.turnStatus == TurnStatus.rollDiceRequestInFlight
            ? Lottie.asset(
                "assets/lotties/Dice Rolling.json",
                width: cellSize * 1.5,
                height: cellSize * 1.5,
                fit: BoxFit.cover,
              )
            : AnimatedContainer(
                padding: EdgeInsets.all(
                  gameController.isMyTurnToRoll() ? cellSize / 8 : cellSize / 5,
                ),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                width: cellSize * (1.5),
                height: cellSize * (1.5),
                child: DiceWidgetMapper(
                  isMyTurn: gameController.isMyTurnToRoll(),
                  value: gameController.gameState!.serverState!.lastDiceValue,
                  size: 72,
                ),
              ),
      ),
    );
  }
}
