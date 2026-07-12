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
    final maxAvailableWidth = screenWidth; // 90% عرض صفحه
    final maxAvailableHeight = screenHeight;

    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.sentiment_dissatisfied_rounded,
          size: 85,
          color: Colors.amber.shade600,
        ),
        SizedBox(height: boardSize * 0.01),
        Text(
          'Do you want Exit?',
          style: TextStyle(
            fontSize: boardSize * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        SizedBox(height: boardSize * 0.016),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: boardSize * 0.06,
                  vertical: boardSize * 0.03,
                ),
              ),
              child: Text(
                'No!',
                style: TextStyle(
                  fontSize: boardSize * 0.03,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(width: boardSize * 0.01),
            ElevatedButton(
              onPressed: () {
                ref.read(gameControllerProvider.notifier).exitGame();
                ref.read(globalLoadingProvider.notifier).start("exit_game");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: boardSize * 0.06,
                  vertical: boardSize * 0.03,
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white,)
                  : Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: boardSize * 0.03,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
