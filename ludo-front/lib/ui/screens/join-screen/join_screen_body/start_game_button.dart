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
    // حذف عرض ثابت دکمه برای ریسپانسیو شدن کامل در Row
    final double buttonHeight = (boardSize * 0.18).clamp(50.0, 100.0);
    final double radiusValue = boardSize * 0.03;
    final borderRadius = BorderRadius.circular(radiusValue);

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF334155),
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
              mainAxisSize: MainAxisSize.min, // جلوگیری از اشغال فضای اضافی عمودی
              children: [
                Text(
                  _getModeLabel(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: (boardSize * 0.038).clamp(11.0, 14.0),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: boardSize * 0.004),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amberAccent,
                      size: (boardSize * 0.038).clamp(12.0, 16.0),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        entryFee == 0 ? "Free" : "$entryFee",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: (boardSize * 0.034).clamp(10.0, 12.0),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      fontSize: (boardSize * 0.032).clamp(9.0, 11.0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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