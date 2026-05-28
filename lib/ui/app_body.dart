import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/home.dart';

class AppBody extends StatelessWidget {
  AppBody({super.key});

  final GameController gameController = GameController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Ludo')),
        backgroundColor: Colors.white12,
      ),
      body: Home(gameController: gameController),
    );
  }
}
