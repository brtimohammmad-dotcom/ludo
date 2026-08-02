import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/utils/avatar.dart';

class PlayerProfileAlert extends ConsumerWidget {
  const PlayerProfileAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(
      gameControllerProvider.select((s) => s?.livePlayer),
    );
    // محاسبه عرض صفحه برای ریسپانسیو‌سازی کامل
    final double screenWidth = MediaQuery.of(context).size.width;
      final double base = (screenWidth * 0.85).clamp(0, 600);

    // رنگ زمردی اختصاصی
    const Color emeraldColor = Color(0xFF10B981);

    // استخراج اطلاعات کاربر با مقادیر پیش‌فرض
    final String name = player?.username ?? player?.username ?? "Player";
    final String? avatarUrl = player?.avatarUrl;
    final int coins = player?.coin ?? 0;
    final int wins = player?.wins ?? 0;
    final int losses = player?.losses ?? 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.06),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(base * 0.06),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آواتار ریسپانسیو
            UserAvatar(
              url: avatarUrl,
              size: base * 0.22,
              borderColor: Colors.amberAccent,
              borderWidth: 2,
            ),
            SizedBox(height: base * 0.03),

            // نام کاربر
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: base * 0.025),

            // نمایش سکه‌ها
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: base * 0.04,
                vertical: base * 0.018,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(base * 0.05),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: base * 0.05,
                    color: Colors.amberAccent,
                  ),
                  SizedBox(width: base * 0.015),
                  Text(
                    context.num(coins),
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: base * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: base * 0.05),

            // آمار برد و باخت در دو باکس مجزا (کاملاً ریسپانسیو)
            Row(
              children: [
                // باکس بردها
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: base * 0.035),
                    decoration: BoxDecoration(
                      color: emeraldColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(base * 0.03),
                      border: Border.all(
                        color: emeraldColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.tr('Wins'),
                          style: TextStyle(
                            color: emeraldColor,
                            fontSize: base * 0.032,
                          ),
                        ),
                        SizedBox(height: base * 0.01),
                        Text(
                          context.num(wins),
                          style: TextStyle(
                            color: emeraldColor,
                            fontSize: base * 0.048,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: base * 0.03),
                // باکس باخت‌ها
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: base * 0.035),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(base * 0.03),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.tr('Losses'),
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: base * 0.032,
                          ),
                        ),
                        SizedBox(height: base * 0.01),
                        Text(
                          context.num(losses),
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: base * 0.048,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: base * 0.06),

            // دکمه بستن
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    context.tr('OK'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: base * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
