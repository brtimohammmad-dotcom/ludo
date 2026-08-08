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

    final double base = boardSize * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.05),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 1.8,
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
              color: const Color(0xFFFFD700),
            ),
            SizedBox(height: base * 0.02),

            // عنوان
            Text(
              context.tr('Daily Rewards'),
              style: TextStyle(
                color: const Color(0xFFFFF8DC),
                fontSize: base * 0.055,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: base * 0.015),

            // توضیحات
            Text(
              context.tr('Daily Reward Text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFD4AF37),
                fontSize: base * 0.032,
              ),
            ),
            SizedBox(height: base * 0.05),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: base * 0.02,
                mainAxisSpacing: base * 0.02,
                childAspectRatio: 0.85,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final int dayNumber = index + 1;

                final isClaimed = dayNumber < (livePlayer?.rewardStreak ?? 1);
                final isCurrent =
                    dayNumber == livePlayer?.rewardStreak && (canClaim ?? false);

                return Container(
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? const Color(0xFF8B5A2B)
                        : (isClaimed ? Colors.black38 : const Color(0xFF1E120B)),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFD700)
                          : (isClaimed ? Colors.greenAccent : const Color(0xFF5C3613)),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${context.tr('Day')} ${context.num(dayNumber)}',
                        style: TextStyle(
                          color: const Color(0xFFFFF8DC),
                          fontSize: base * 0.028,
                        ),
                      ),
                      SizedBox(height: base * 0.01),
                      Icon(
                        isClaimed ? Icons.check_circle : Icons.monetization_on,
                        color: isClaimed ? Colors.greenAccent : const Color(0xFFFFD700),
                        size: base * 0.045,
                      ),
                      SizedBox(height: base * 0.01),
                      Text(
                        "+${context.num(rewards[index])}",
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: const Color(0xFFFFF8DC),
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
              onTap: ((canClaim ?? false) && !isLoading)
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
                  gradient: ((canClaim ?? false) && !isLoading)
                      ? const LinearGradient(
                    colors: [
                      Color(0xFF8B5A2B),
                      Color(0xFF6F431A),
                    ],
                  )
                      : const LinearGradient(
                    colors: [Color(0xFF381F12), Color(0xFF2A160C)],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.035),
                  border: Border.all(
                    color: (canClaim ?? false)
                        ? const Color(0xFFFFD700)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                    width: base * 0.05,
                    height: base * 0.05,
                    child: const CircularProgressIndicator(
                      color: Color(0xFFFFD700),
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    (canClaim ?? false)
                        ? context.tr('Claim Reward')
                        : context.tr('Already Claimed'),
                    style: TextStyle(
                      color: (canClaim ?? false)
                          ? const Color(0xFFFFF8DC)
                          : Colors.grey.shade500,
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
                  color: const Color(0xFFD4AF37),
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