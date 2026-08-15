import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/utils/alerts/daily_reward_dialog.dart';

class DailyRewardAndCoinBox extends ConsumerWidget {
  final double boardSize;

  const DailyRewardAndCoinBox({super.key, required this.boardSize});

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
        CoinBox(
          coins: coins,
          height: 38,
          fontSize: 13,
          iconSize: 16,
        ),
        const SizedBox(width: 6),
        DailyRewardButton(boardSize: boardSize, canClaim: canClaim),
      ],
    );
  }
}

class DailyRewardButton extends StatelessWidget {
  const DailyRewardButton({
    super.key,
    required this.boardSize,
    required this.canClaim,
  });

  final double boardSize;
  final bool canClaim;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => DailyRewardDialog(boardSize: boardSize),
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
                : [const Color(0xFF4A2A18), const Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: canClaim
                ? Colors.white
                : const Color(0xFFD4AF37).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canClaim
                  ? const Color(0xFFFF8C00).withValues(alpha: 0.6)
                  : Colors.black38,
              blurRadius: canClaim ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.card_giftcard_rounded,
          color: canClaim ? Colors.white : const Color(0xFFD4AF37),
          size: 18,
        ),
      ),
    );
  }
}

class CoinBox extends StatelessWidget {
  const CoinBox({
    super.key,
    required this.coins,
    this.height = 46.0,
    this.fontSize = 15.0,
    this.iconSize = 20.0,
  });

  final int coins;
  final double height;
  final double fontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.35),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
          width: 1.8,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black45, offset: Offset(0, 3), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD700),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 8,
                  spreadRadius: -1,
                ),
              ],
            ),
            child: Icon(
              Icons.monetization_on_rounded,
              color: const Color(0xFF522800),
              size: iconSize,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.num(coins),
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
