import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/ui/screens/join-screen/join_screen.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class WaitingForPlayersAlert extends ConsumerWidget {
  const WaitingForPlayersAlert({super.key, required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      globalLoadingProvider.select((state) => state.contains("cancel_game")),
    );
    final gameController = ref.read(gameControllerProvider.notifier);
    final gameState = gameController.currentGameState;
    final state = gameState?.serverState;
    final size = MediaQuery.of(context).size;
    final boardSize = size.width < size.height
        ? size.width
        : size.height * 0.86;

    final numberOfPlayers = state?.numberOfPlayers ?? 2;
    final requiredPlayers = numberOfPlayers < 0
        ? -numberOfPlayers
        : (numberOfPlayers == -1 ? 2 : numberOfPlayers);

    // 🟢 بهینه‌سازی طلایی: فقط بخش تعداد اعضا واچ می‌شود و بقیه ویجت‌ها ری‌بیلد نمی‌شوند
    final currentPlayers =
        ref.watch(
          gameControllerProvider.select(
            (state) => state?.serverState?.players.length,
          ),
        ) ??
        0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🟢 انتقال انیمیشن سنگین به یک ویجت ایزوله و مستقل با کلمه کلیدی const
          LoadingAnimationWidget.dotsTriangle(
            color: Colors.white,
            size: boardSize * 0.25,
          ),

          SizedBox(height: boardSize * 0.025),

          Text(
            'Waiting for Players',
            style: TextStyle(
              fontSize: boardSize * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: boardSize * 0.02),

          // بخش وضعیت صندلی‌ها
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: requiredPlayers == 2
                  ? boardSize * 0.06
                  : boardSize * 0.03,
              vertical: boardSize * 0.025,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(boardSize * 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(requiredPlayers, (index) {
                final isJoined = index < currentPlayers;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: requiredPlayers == 2
                        ? boardSize * 0.015
                        : boardSize * 0.005,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    // استفاده از یک کرو سبک‌تر
                    width: requiredPlayers == 2
                        ? boardSize * 0.09
                        : boardSize * 0.08,
                    height: requiredPlayers == 2
                        ? boardSize * 0.09
                        : boardSize * 0.08,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isJoined
                          ? Colors.green.shade600
                          : Colors.grey.shade300,
                    ),
                    child: Icon(
                      isJoined ? Icons.person : Icons.person_outline,
                      color: isJoined ? Colors.white : Colors.grey.shade500,
                      size: boardSize * 0.05,
                    ),
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: boardSize * 0.02),

          Text(
            '$currentPlayers / $requiredPlayers Joined',
            style: TextStyle(
              fontSize: boardSize * 0.04,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: boardSize * 0.04),

          if (state?.mode == GameMode.friendly) ...[
            ElevatedButton.icon(
              onPressed: () {
                final gameId = state?.gameId;
                TelegramWebApp.instance.switchInlineQuery("game_$gameId", [
                  ChatType.groups,
                  ChatType.users,
                  ChatType.channels,
                ]);
              },
              icon: const Icon(Icons.share, color: Colors.black87),
              label: const Text('Share Invite Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(
                  horizontal: boardSize * 0.08,
                  vertical: boardSize * 0.03,
                ),
                textStyle: TextStyle(
                  fontSize: boardSize * 0.025,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(boardSize * 0.04),
                ),
              ),
            ),
            SizedBox(height: boardSize * 0.03),
          ],

          ElevatedButton(
            onPressed: onExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: boardSize * 0.09,
                vertical: boardSize * 0.025,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(boardSize * 0.04),
              ),
              textStyle: TextStyle(
                fontSize: boardSize * 0.03,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: isLoading ?const CircularProgressIndicator(color: Colors.white,) : Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
