import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class ExitButtonAlert extends ConsumerWidget {
  const ExitButtonAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      globalLoadingProvider.select((state) => state.contains("exit_game")),
    );
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxAvailableWidth = screenWidth;
    final maxAvailableHeight = screenHeight;

    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);
    final double base = boardSize * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.06),
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
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: base * 0.15,
              color: const Color(0xFFFFD700),
            ),
            SizedBox(height: base * 0.03),
            Text(
              context.tr('exit alert title'),
              style: TextStyle(
                fontSize: base * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFF8DC),
              ),
            ),
            SizedBox(height: base * 0.06),
            Row(
              children: [
                // دکمه خیر (ماندن در بازی)
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: base * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                        ),
                        borderRadius: BorderRadius.circular(base * 0.03),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('No'),
                          style: TextStyle(
                            fontSize: base * 0.035,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFF8DC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: base * 0.03),
                // دکمه بله (خروج)
                Expanded(
                  child: GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                      ref.read(gameControllerProvider.notifier).exitGame();
                      ref.read(globalLoadingProvider.notifier).start("exit_game");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: base * 0.03),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFB91C1C),
                            Color(0xFF7F1D1D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(base * 0.03),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                          width: base * 0.045,
                          height: base * 0.045,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          context.tr('Yes'),
                          style: TextStyle(
                            fontSize: base * 0.035,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}