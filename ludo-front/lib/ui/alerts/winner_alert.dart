import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/join_screen.dart';



class WinnerAlert extends StatelessWidget {
  const WinnerAlert({
    super.key,
    required this.winner,
    required this.gameController,
  });

  final Player winner;
  final GameController gameController;

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
        Text('👑', style: TextStyle(fontSize: boardSize * 0.2)),
        SizedBox(height: boardSize * 0.01),
        Text(
          '!برنده شد',
          style: TextStyle(
            fontSize: boardSize * 0.1,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: boardSize * 0.008),
        Container(
          padding: EdgeInsets.all(boardSize * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(boardSize * 0.06),
          ),
          child: Text(
            winner.username,
            style: TextStyle(
              fontSize: boardSize * 0.06,
              fontWeight: FontWeight.bold,
              color: winner.color.toColor(),
            ),
          ),
        ),
        SizedBox(height: boardSize * 0.016),
        ElevatedButton(
          onPressed: () {
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
              horizontal: boardSize * 0.09,
              vertical: boardSize * 0.03,
            ),
          ),
          child: Text(
            'بستن',
            style: TextStyle(
              fontSize: boardSize * 0.03,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// اکستنشن برای تبدیل PlayerColor به Color
extension PlayerColorExtension on PlayerColor {
  Color toColor() {
    switch (this) {
      case PlayerColor.red:
        return Colors.red.shade700;
      case PlayerColor.green:
        return Colors.green.shade700;
      case PlayerColor.yellow:
        return Colors.yellow.shade700;
      case PlayerColor.blue:
        return Colors.blue.shade700;
    }
  }
}
