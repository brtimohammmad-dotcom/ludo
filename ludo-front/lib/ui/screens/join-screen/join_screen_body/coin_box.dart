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
        // 🪙 کپسول نمایش سکه
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFB703),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFFFB703),
                      blurRadius: 6,
                      spreadRadius: -1,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFF522800),
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // 🎁 دکمه پاداش روزانه
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canClaim
                    ? [const Color(0xFFFFD700), const Color(0xFFFF8C00)]
                    : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: canClaim
                    ? Colors.white
                    : const Color(0xFF334155),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: canClaim
                      ? const Color(0xFFFF8C00).withValues(alpha: 0.5)
                      : Colors.black26,
                  blurRadius: canClaim ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: canClaim ? Colors.white : Colors.grey.shade400,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}