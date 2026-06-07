import 'package:flutter/material.dart';

class ReconnectingFailedAlert extends StatelessWidget {
  final VoidCallback onHomePressed;

  const ReconnectingFailedAlert({super.key, required this.onHomePressed});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final maxAvailableWidth = screenWidth;
    final maxAvailableHeight = screenHeight;
    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);

    return Center(
      child: Container(
        width: boardSize * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // جمع شدن کارت به اندازه محتوا
          children: [
            // آیکون با رنگ هشدار ملایم
            Icon(
              Icons.signal_wifi_connected_no_internet_4_outlined,
              size: boardSize * 0.18,
              color: Colors.redAccent.shade400,
            ),
            const SizedBox(height: 16),

            // متن اصلی خطا
            const Text(
              "اتصال برقرار نشد",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Vazir', // در صورت داشتن فونت فارسی، در غیر این صورت حذف شود
              ),
            ),
            const SizedBox(height: 8),

            // متن توضیحات تکمیلی
            Text(
              "زمان تلاش برای اتصال به پایان رسید. لطفاً وضعیت اینترنت خود را بررسی کنید.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // دکمه شیک برای بازگشت به خانه
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade700,
                foregroundColor: Colors.white,
                minimumSize: Size(boardSize * 0.5, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              onPressed: onHomePressed,
              icon: const Icon(Icons.home_rounded, size: 20),
              label: const Text(
                "بازگشت به منو",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}