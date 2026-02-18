import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/board.dart';

class Home extends StatelessWidget {
  final GameController gameController;

  const Home({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [Expanded(child: Board(gameController: gameController,))]),
    );
  }
}
