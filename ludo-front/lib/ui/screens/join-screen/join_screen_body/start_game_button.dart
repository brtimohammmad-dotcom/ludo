import 'package:flutter/material.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;
  final double boardSize;
  final int entryFee;
  final int prizePool;
  final Color themeColor; // رنگ تم اختصاصی لول (مثلا طلایی برای گلد)

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
    required this.boardSize,
    required this.entryFee,
    required this.prizePool,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = numberOfPlayers == -1;

    String modeLabel = "";
    if (numberOfPlayers == -1) {
      modeLabel = "Friends";
    } else if (numberOfPlayers == 2 || numberOfPlayers == -2) {
      modeLabel = "2 Players";
    } else {
      modeLabel = "4 Players";
    }

    final buttonWidth = isWide ? boardSize * 0.675 : boardSize * 0.33;
    final buttonHeight = boardSize * 0.20;
    final borderRadius = BorderRadius.circular(boardSize * 0.02);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(
            color: themeColor.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: borderRadius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  modeLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: boardSize * 0.04,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: boardSize * 0.004),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amberAccent, size: boardSize * 0.04),
                    SizedBox(width: boardSize * 0.005),
                    Text(
                      entryFee == 0 ? "Free" : "$entryFee",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: boardSize * 0.029,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (prizePool > 0) ...[
                  SizedBox(height: boardSize * 0.002),
                  Text(
                    "Win: +$prizePool",
                    style: TextStyle(
                      color: Colors.amberAccent.shade100,
                      fontWeight: FontWeight.bold,
                      fontSize: boardSize * 0.030,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}