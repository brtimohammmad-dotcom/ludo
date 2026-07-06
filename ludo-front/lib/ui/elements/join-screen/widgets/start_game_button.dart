import 'dart:ui';
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

    // 🪙 تنظیم رنگ تم دکمه بر اساس نوع بازی (سبز برای دوستانه، آبی/بنفش نئون برای جهانی)
    final themeColor = isFriendly ? Colors.greenAccent : Colors.cyanAccent;
    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // 🪄 افکت شیشه‌ای با ClipRRect و BackdropFilter
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // میزان تاری پشت شیشه
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              // رنگ سفیدِ بسیار شفاف برای بدنه شیشه
              color: Colors.white.withValues(alpha: 0.07),
              // حاشیه درخشان و ظریف برای دادن حس ضخامت به شیشه
              border: Border.all(
                color: themeColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                padding: EdgeInsets.symmetric(vertical: boardSize * 0.008, horizontal: boardSize * 0.01),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onPressed,
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
                      shadows: const [
                        Shadow(color: Colors.black38, offset: Offset(0, 1.5), blurRadius: 3)
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: boardSize * 0.005),

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
      ),
    );
  }
}