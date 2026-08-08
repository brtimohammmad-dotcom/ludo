import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class WinPrize extends ConsumerWidget {
  const WinPrize({super.key, required this.boardSize});
  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    return Directionality(
      textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: boardSize * 0.02,
          vertical: boardSize * 0.01,
        ),
        decoration: BoxDecoration(
          // 🏆 پس‌زمینه چوبی صیقل‌خورده با استروک طلایی
          gradient: const LinearGradient(
            colors: [Color(0xFF3B2012), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(boardSize * 0.015),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: const Color(0xFFFFD700),
              size: boardSize * 0.03,
            ),
            SizedBox(width: boardSize * 0.01),
            Text(
              ref.watch(
                gameControllerProvider.select((s) => context.num(s!.winPrice())),
              ),
              style: TextStyle(
                color: const Color(0xFFFFF8DC),
                fontWeight: FontWeight.bold,
                fontSize: boardSize * 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}