import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';

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
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: base * 0.15,
              color: Colors.amberAccent,
            ),
            SizedBox(height: base * 0.03),
            Text(
              'Do you want to exit?',
              style: TextStyle(
                fontSize: base * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                        color: const Color(0xFF334155), // خاکستری تیره ملایم
                        borderRadius: BorderRadius.circular(base * 0.03),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Center(
                        child: Text(
                          'No',
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
                        gradient: LinearGradient(
                          colors: [
                            Colors.redAccent.shade700,
                            Colors.red.shade900,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(base * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
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
                          'Yes',
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