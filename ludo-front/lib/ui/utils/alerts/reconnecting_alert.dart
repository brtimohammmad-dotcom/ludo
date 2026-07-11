import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ReconnectingAlert extends StatelessWidget {
  const ReconnectingAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // انتخاب بعد کوچک‌تر برای واکنش‌گرایی بر اساس سایز بورد بازی
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    // مقیاس‌دهی داینامیک ابعاد آلرت بر اساس برد بازی
    final double dialogWidth = boardSize * 0.75;
    final double loadingSize = boardSize * 0.14;
    final double titleFontSize = boardSize * 0.048;
    final double detailFontSize = boardSize * 0.034;

    return Center(
      child: Container(
        width: dialogWidth,
        padding: EdgeInsets.symmetric(
          horizontal: boardSize * 0.06,
          vertical: boardSize * 0.07,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF161522), // تِم تاریک و منسجم بازی
          borderRadius: BorderRadius.circular(boardSize * 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // جمع شدن کارت متناسب با محتوا
          children: [
            // انیمیشن لودینگ ضربان با ابعاد واکنش‌گرا
            LoadingAnimationWidget.beat(
              color: Colors.white,
              size: loadingSize,
            ),
            SizedBox(height: boardSize * 0.04),

            // متن وضعیت اتصال مجدد
            Text(
              "Reconnecting...",
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: boardSize * 0.015),

            // متن توضیحات فرعی
            Text(
              "Connecting to server, please wait.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: detailFontSize,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}