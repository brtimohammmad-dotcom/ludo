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

  // حذف شرط -1 (Friends) و ساده‌سازی کامل متد متنی
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
          borderRadius: borderRadius,
          border: Border.all(
            color: themeColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.1),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.01),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getModeLabel(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (boardSize * 0.040).clamp(11.0, 16.0), // کنترل فونت برای عدم اورفلو در رزولوشن‌های مختلف
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
                          style: TextStyle(
                            color: const Color(0xE6FFFFFF),
                            fontSize: (boardSize * 0.030).clamp(9.0, 14.0),
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
                          fontSize: (boardSize * 0.030).clamp(9.0, 14.0),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}