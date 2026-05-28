import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/join_screen.dart';

class ExitAlert extends StatelessWidget {
  const ExitAlert({
    super.key,
    required this.boardSize,
    required this.lastGameController,
    required this.gameController,
  });

  final double boardSize;
  final GameController lastGameController;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: boardSize * 0.5,
        padding: EdgeInsets.all(boardSize * 0.02),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueGrey, Colors.grey],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(boardSize * 0.09),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ایموجی تاج بزرگ
            Text('🥺', style: TextStyle(fontSize: boardSize * 0.2)),
            SizedBox(height: boardSize * 0.01),
            Text(
              'آیا میخواهید از بازی خارج شوید؟',
              style: TextStyle(
                fontSize: boardSize * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: boardSize * 0.016),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: boardSize * 0.06,
                      vertical: boardSize * 0.03,
                    ),
                  ),
                  child: Text(
                    'لغو',
                    style: TextStyle(
                      fontSize: boardSize * 0.03,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: boardSize * 0.01,),
                ElevatedButton(
                  onPressed: () {
                    lastGameController.exitGame();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            JoinScreen(gameController: gameController),
                      ),
                          (route) => false, // حذف همه صفحات قبلی
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: boardSize * 0.06,
                      vertical: boardSize * 0.03,
                    ),
                  ),
                  child: Text(
                    'تایید',
                    style: TextStyle(
                      fontSize: boardSize * 0.03,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}