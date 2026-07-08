import 'package:flutter/material.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;
  final double boardSize;
  final int entryFee;
  final int prizePool;

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
    required this.boardSize,
    required this.entryFee,
    required this.prizePool,
  });

  @override
  Widget build(BuildContext context) {
    final isFriendly = numberOfPlayers < 0;
    final isWide = numberOfPlayers == -1;

    String modeLabel = "";
    if (numberOfPlayers == -1) {
      modeLabel = "Friends";
    } else if (numberOfPlayers == 2 || numberOfPlayers == -2) {
      modeLabel = "2 Players";
    } else {
      modeLabel = "4 Players";
    }

    final buttonWidth = isWide ? boardSize * 0.45 : boardSize * 0.22;
    final buttonHeight = boardSize * 0.12;
    final borderRadius = BorderRadius.circular(boardSize * 0.02);
    final themeColor = isFriendly ? Colors.greenAccent : Colors.cyanAccent;

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          // 🟢 بُوردر را به اینجا (لایه اصلی) آوردیم تا قطعاً و بدون غیب شدن رندر شود
          border: Border.all(
            color: themeColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          // سایه فلت ۳بعدیِ کاملاً سبک بدون بلور
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.15),
              blurRadius: 0,
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
              // شبیه‌سازی شیشه با شیب رنگ آلفادار
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
                // ۱. عنوان بازی
                Text(
                  modeLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: boardSize * 0.024,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: boardSize * 0.004),

                // ۲. هزینه ورود
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amberAccent, size: boardSize * 0.02),
                    SizedBox(width: boardSize * 0.005),
                    Text(
                      entryFee == 0 ? "Free" : "$entryFee",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: boardSize * 0.018,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // ۳. مقدار جایزه برد
                if (prizePool > 0) ...[
                  SizedBox(height: boardSize * 0.002),
                  Text(
                    "Win: +$prizePool",
                    style: TextStyle(
                      color: Colors.amberAccent.shade100,
                      fontWeight: FontWeight.bold,
                      fontSize: boardSize * 0.016,
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