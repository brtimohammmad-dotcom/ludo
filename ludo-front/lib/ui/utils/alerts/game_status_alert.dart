import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
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
    final double base = boardSize * 0.85;

    final numberOfPlayers = state?.numberOfPlayers ?? 2;
    final requiredPlayers = numberOfPlayers < 0
        ? -numberOfPlayers
        : (numberOfPlayers == -1 ? 2 : numberOfPlayers);

    final currentPlayers =
        ref.watch(
          gameControllerProvider.select(
                (state) => state?.serverState?.players.length,
          ),
        ) ??
            0;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: LoadingAnimationWidget.dotsTriangle(
                  color: const Color(0xFFFFD700),
                  size: base * 0.18,
                ),
              ),
              SizedBox(height: base * 0.04),
              Text(
                context.tr('Game Status Alert Title'),
                style: TextStyle(
                  fontSize: base * 0.05,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFF8DC),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: base * 0.04),
              // صندلی‌ها با تم چوبی کدر
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: base * 0.05,
                    vertical: base * 0.03,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E120B),
                    borderRadius: BorderRadius.circular(base * 0.04),
                    border: Border.all(
                      color: const Color(0xFF5C3613),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(requiredPlayers, (index) {
                      final isJoined = index < currentPlayers;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: base * 0.015),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: base * 0.09,
                          height: base * 0.09,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isJoined
                                ? const Color(0xFF276A3C)
                                : const Color(0xFF381F12),
                            border: Border.all(
                              color: isJoined
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF5C3613),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isJoined ? Icons.person : Icons.person_outline,
                            color: isJoined
                                ? const Color(0xFFFFF8DC)
                                : const Color(0xFF8B5A2B),
                            size: base * 0.05,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: base * 0.03),
              Text(
                '${context.num(currentPlayers)} / ${context.num(requiredPlayers)} ${context.tr('Joined')}',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: base * 0.035,
                  color: const Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: base * 0.05),
              if (state?.type == GameType.friendly) ...[
                GestureDetector(
                  onTap: () {
                    final gameId = state?.gameId;
                    TelegramWebApp.instance.switchInlineQuery("game_$gameId", [
                      ChatType.groups,
                      ChatType.users,
                      ChatType.channels,
                    ]);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: base * 0.035),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                      ),
                      borderRadius: BorderRadius.circular(base * 0.03),
                      border: Border.all(color: const Color(0xFFFFD700)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            color: const Color(0xFFFFF8DC),
                            size: base * 0.045,
                          ),
                          SizedBox(width: base * 0.02),
                          Text(
                            'Share Invite Link',
                            style: TextStyle(
                              color: const Color(0xFFFFF8DC),
                              fontSize: base * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: base * 0.03),
              ],
              GestureDetector(
                onTap: onExit,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: base * 0.035),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A160C),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: const Color(0xFF5C3613),
                    ),
                  ),
                  child: Center(
                    child: isLoading
                        ? SizedBox(
                      width: base * 0.045,
                      height: base * 0.045,
                      child: const CircularProgressIndicator(
                        color: Color(0xFFFFD700),
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      context.tr('Cancel'),
                      style: TextStyle(
                        color: Colors.redAccent.shade100,
                        fontSize: base * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}