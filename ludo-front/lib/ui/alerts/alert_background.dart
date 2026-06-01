import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/ui/alerts/winner_alert.dart';

class AlertBackground extends StatelessWidget {
  final GameController gameController = GameController();
  final Widget alert;


  AlertBackground({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxAvailableWidth = screenWidth; // 90% عرض صفحه
    final maxAvailableHeight = screenHeight;

    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);
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
        child: alert
      ),
    );
  }
}