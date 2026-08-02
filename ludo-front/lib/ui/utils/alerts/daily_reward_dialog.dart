import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class DailyRewardDialog extends ConsumerWidget {
  final double boardSize;

  const DailyRewardDialog({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePlayer = ref.watch(
      gameControllerProvider.select((state) => state?.livePlayer),
    );
    final isLoading = ref.watch(globalLoadingProvider).contains('daily_reward');
    final canClaim = livePlayer?.canClaimDailyReward;
    final List<int> rewards = [100, 150, 200, 250, 300, 350, 500];

    final double base =
        boardSize * 0.85; // محدود کردن عرض دیالوگ متناسب با برد بازی

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.05),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B), // تم تاریک بازی
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون هدیه
            Icon(
              Icons.card_giftcard,
              size: base * 0.12,
              color: Colors.amberAccent,
            ),
            SizedBox(height: base * 0.02),

            // عنوان
            Text(
              context.tr('Daily Rewards'),
              style: TextStyle(
                color: Colors.white,
                fontSize: base * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: base * 0.015),

            // توضیحات
            Text(
              context.tr('Daily Reward Text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: base * 0.032,
              ),
            ),
            SizedBox(height: base * 0.05),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // کاملاً ثابت
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // ۴ ستون در هر ردیف
                crossAxisSpacing: base * 0.02,
                mainAxisSpacing: base * 0.02,
                childAspectRatio: 0.85, // تناسب ابعاد کارت‌ها
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final int dayNumber = index + 1;

                final isClaimed = dayNumber < livePlayer!.rewardStreak;
                final isCurrent =
                    dayNumber == livePlayer.rewardStreak && canClaim!;

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.amber.withValues(alpha: 0.15)
                        : (isClaimed ? Colors.black38 : Colors.white10),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.amber
                          : (isClaimed ? Colors.green : Colors.white12),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr('Day')} ${context.num(dayNumber)}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: base * 0.028,
                        ),
                      ),
                      SizedBox(height: base * 0.01),
                      Icon(
                        isClaimed ? Icons.check_circle : Icons.monetization_on,
                        color: isClaimed ? Colors.green : Colors.amber,
                        size: base * 0.045,
                      ),
                      SizedBox(height: base * 0.01),
                      Text(
                        "+${context.num(rewards[index])}",
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: base * 0.028,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: base * 0.06),

            // دکمه کلیم جایزه
            GestureDetector(
              onTap: (canClaim! && !isLoading)
                  ? () {
                      ref
                          .read(globalLoadingProvider.notifier)
                          .start('daily_reward');
                      ref
                          .read(gameControllerProvider.notifier)
                          .claimDailyReward();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: (canClaim && !isLoading)
                      ? LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade700,
                          ],
                        )
                      : const LinearGradient(
                          colors: [Colors.grey, Colors.blueGrey],
                        ),
                  borderRadius: BorderRadius.circular(base * 0.035),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: base * 0.05,
                          height: base * 0.05,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          canClaim
                              ? context.tr('Claim Reward')
                              : context.tr('Already Claimed'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: base * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: base * 0.02),

            // دکمه بستن دیالوگ
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('Close'),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: base * 0.035,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
