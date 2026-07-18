import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/utils/alerts/daily_reward_dialog.dart';

class CoinBox extends ConsumerWidget {
  final double boardSize;

  const CoinBox({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePlayer = ref.watch(
      gameControllerProvider.select((state) => state?.livePlayer),
    );
    final int coins = livePlayer?.coin ?? 0;
    final bool canClaim = livePlayer?.canClaimDailyReward ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // رنگ سالید مات
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF334155), width: 1.0),
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
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => DailyRewardDialog(
                boardSize: boardSize,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(
                color: canClaim ? Colors.amber : const Color(0xFF334155),
                width: 1.0,
              ),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: canClaim ? Colors.amberAccent : Colors.grey,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}