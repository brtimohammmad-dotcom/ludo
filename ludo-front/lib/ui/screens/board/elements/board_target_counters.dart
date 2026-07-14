import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/screens/board/elements/target_counter_widget.dart';

class BoardTargetCounters extends StatelessWidget {
  final double cellSize;
  const BoardTargetCounters({super.key, required this.cellSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TargetCounterWidget(playerColor: PlayerColor.red, positionLeft: cellSize * 5, positionTop: cellSize * 6),
        TargetCounterWidget(playerColor: PlayerColor.green, positionLeft: cellSize * 6, positionTop: cellSize * 5),
        TargetCounterWidget(playerColor: PlayerColor.yellow, positionLeft: cellSize * 5, positionTop: cellSize * 4),
        TargetCounterWidget(playerColor: PlayerColor.blue, positionLeft: cellSize * 4, positionTop: cellSize * 5),
      ],
    );
  }
}