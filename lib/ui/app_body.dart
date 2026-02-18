import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/home.dart';

class AppBody extends StatefulWidget {
  const AppBody({super.key});

  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  GameController gameController = GameController();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    gameController.startGame();
  }
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
  @override
  void dispose() {
    super.dispose();
    // TODO: implement dispose
    gameController.dispose();
  }
}
