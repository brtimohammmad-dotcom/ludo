import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class ReconnectingFailedAlert extends StatelessWidget {
  final VoidCallback onReconnectPressed;
  const ReconnectingFailedAlert({super.key, required this.onReconnectPressed});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final maxAvailableWidth = screenWidth;
    final maxAvailableHeight = screenHeight;
    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);

    final double base = boardSize * 0.85; // پایه مقیاس‌دهی منسجم با سایر دیالوگ‌ها

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.06),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // تم تاریک منسجم بازی
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.5), // مرز قرمز نئونی به نشانه خطا
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // جمع شدن کارت متناسب با محتوا
          children: [
            // آیکون خطا با رنگ قرمز نئونی ملایم
            Icon(
              Icons.signal_wifi_connected_no_internet_4_outlined,
              size: base * 0.15,
              color: Colors.redAccent.shade400,
            ),
            SizedBox(height: base * 0.04),

            // عنوان خطا
            Text(
              context.tr('reconnecting failed alert title'),
              style: TextStyle(
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: base * 0.02),

            // توضیحات خطا
            Text(
              context.tr('reconnecting failed alert text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: base * 0.032,
                color: Colors.grey.shade400,
                height: 1.4,
              ),
            ),
            SizedBox(height: base * 0.06),

            // دکمه شیک و مدرن تلاش مجدد (تغییر ElevatedButton به GestureDetector با استایل اختصاصی)
            GestureDetector(
              onTap: onReconnectPressed,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade700,
                      Colors.blueGrey.shade900,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.03),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: base * 0.045,
                      ),
                      SizedBox(width: base * 0.02),
                      Text(
                        context.tr('Reconnect'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: base * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}