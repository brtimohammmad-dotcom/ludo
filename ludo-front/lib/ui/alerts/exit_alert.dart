import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/join_screen.dart';

class ExitButtonAlert extends StatelessWidget {
  const ExitButtonAlert({super.key, required this.lastGameController});

  final GameController lastGameController;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxAvailableWidth = screenWidth; // 90% عرض صفحه
    final maxAvailableHeight = screenHeight;

    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);
    return Column(
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
            SizedBox(width: boardSize * 0.01),
            ElevatedButton(
              onPressed: () {
                lastGameController.exitGame();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        JoinScreen(gameController: GameController()),
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
    );
  }
}
