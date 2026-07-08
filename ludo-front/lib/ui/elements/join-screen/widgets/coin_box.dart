import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/utils/alerts/daily_reward_dialog.dart'; // مسیر دیالوگ خودت رو چک کن

class CoinBox extends ConsumerWidget {
  final double boardSize;

  const CoinBox({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePlayer = ref.watch(
      gameControllerProvider.select((state) => state?.livePlayer),
    );
    final int coins = livePlayer?.coin ?? 0;
    final int currentStreak = livePlayer?.rewardStreak ?? 1;
    final bool canClaim = livePlayer?.canClaimDailyReward ?? false;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ۱. باکس نمایش سکه‌ها
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), // فاصله بین باکس سکه و دکمه جایزه
          // ۲. دکمه باز کردن دستی وضعیت جایزه روزانه
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false, // کاربر حتماً باید دکمه را بزند تا دیالوگ بسته شود
                builder: (context) => DailyRewardDialog(
                  currentStreak: currentStreak,
                  canClaim: canClaim,
                  boardSize: boardSize,
                  onClaimPressed: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    // کدهای متد سرور شما...
                  },
                ),
              );

            },
            child: Container(
              padding: const EdgeInsets.all(8),
              // ایجاد پدینگ متقارن برای شکل دایره‌ای/بیضی
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: canClaim ? Colors.amber : Colors.white24,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.card_giftcard,
                color: canClaim ? Colors.amberAccent : Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
