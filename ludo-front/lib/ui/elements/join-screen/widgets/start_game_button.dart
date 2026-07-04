
import 'package:flutter/material.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;
  final double boardSize;

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
    required this.boardSize
  });

  @override
  Widget build(BuildContext context) {
    // amber برای دکمه‌های دوستان (-1, -2, -4) و green برای بازی‌های عمومی
    final isAmber = numberOfPlayers < 0;
    final isWide = numberOfPlayers == -1;

    String label = "";
    if (numberOfPlayers == -1) {
      label = "Friends";
    } else if (numberOfPlayers == 2 || numberOfPlayers == -2) {
      label = "2 Players";
    } else {
      label = "4 Players";
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isWide ? boardSize*0.41 : boardSize*0.2, boardSize*0.08),
        elevation: boardSize*0.003,
        backgroundColor: isAmber ? Colors.amber : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(boardSize*0.005)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style:  TextStyle(color: Colors.white, height: boardSize*0.0015,fontSize: boardSize*0.025,),
        textAlign: TextAlign.center,
      ),
    );
  }
}