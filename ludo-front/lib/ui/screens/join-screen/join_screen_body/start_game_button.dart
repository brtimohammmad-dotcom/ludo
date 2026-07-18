import 'package:flutter/material.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;
  final double boardSize;
  final int entryFee;
  final int prizePool;
  final Color themeColor;

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
    required this.boardSize,
    required this.entryFee,
    required this.prizePool,
    required this.themeColor,
  });

  String _getModeLabel() {
    if (numberOfPlayers == 2 || numberOfPlayers == -2) return "2 Players";
    return "4 Players";
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = boardSize * 0.32;
    final double buttonHeight = boardSize * 0.22;
    final double radiusValue = boardSize * 0.03;
    final borderRadius = BorderRadius.circular(radiusValue);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF334155), // دکمه‌های کاملاً سالید و روان
          borderRadius: borderRadius,
          border: Border.all(
            color: themeColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: InkWell(
            onTap: onPressed,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getModeLabel(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: (boardSize * 0.040).clamp(11.0, 16.0),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: boardSize * 0.006),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amberAccent,
                      size: boardSize * 0.042,
                    ),
                    SizedBox(width: boardSize * 0.008),
                    Text(
                      entryFee == 0 ? "Free" : "$entryFee",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (prizePool > 0) ...[
                  SizedBox(height: boardSize * 0.004),
                  Text(
                    "Win: +$prizePool",
                    style: TextStyle(
                      color: Colors.amberAccent.shade100,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
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