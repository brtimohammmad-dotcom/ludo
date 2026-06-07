import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/board/board.dart';

class JoinScreen extends StatelessWidget {
  final GameController gameController;

  const JoinScreen({super.key, required this.gameController});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade500,
            Colors.blueGrey,
            Colors.blueGrey,
            Colors.blueGrey.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset("assets/lotties/Happy Dice.json",
            width: 200,height: 200,fit: BoxFit.cover),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StartGameButton(gameController: gameController, gameMode: 2),
                SizedBox(width: 20),
                StartGameButton(gameController: gameController, gameMode: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StartGameButton extends StatelessWidget {
  const StartGameButton({
    super.key,
    required this.gameController,
    required this.gameMode,
  });

  final int gameMode;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(120, 50),

        elevation: 3,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: () {
        gameController.startGame(gameMode: gameMode);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Board(gameController: gameController),
          ),
        );
      },
      child: Text(
        gameMode == 2 ? "شروع بازی\n(دو نفره)" : "شروع بازی\n(چهار نفره)",
        style: TextStyle(color: Colors.white,height: 1.5),textAlign: TextAlign.center,
      ),
    );
  }
}
