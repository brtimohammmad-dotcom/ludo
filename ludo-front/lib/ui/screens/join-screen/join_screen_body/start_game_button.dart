import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;
  final int prizePool;
  final Color themeColor;
  final bool big;

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
    required this.prizePool,
    required this.themeColor,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    final String modeText = (numberOfPlayers == 2 || numberOfPlayers == -2)
        ? context.tr('2 Players')
        : context.tr('4 Players');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: big ? 50 : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            // رنگ چوب افرا برای دکمه تا روی کارت چوبی کاملاً خودش را نشان دهد
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8B5A2B), // چوب روشن‌تر
                Color(0xFF6F431A), // شیار چوبی
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: const Color(0xFFE5C158), // حاشیه طلایی بر برجسته
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // تعداد بازیکنان
              Row(
                children: [
                  Icon(
                    numberOfPlayers == 2 ? Icons.person : Icons.groups,
                    color: const Color(0xFFFFF8DC),
                    size: big ? 20 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    modeText,
                    style: TextStyle(
                      color: const Color(0xFFFFF8DC),
                      fontWeight: FontWeight.w900,
                      fontSize: big ? 14 : 12,
                    ),
                  ),
                ],
              ),

              // جایزه برد
              if (prizePool > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF276A3C), // سبز تیره سنتی
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.6),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    "+${context.num(prizePool)}",
                    style: TextStyle(
                      color: const Color(0xFF4ADE80),
                      fontWeight: FontWeight.w900,
                      fontSize: big ? 12 : 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}