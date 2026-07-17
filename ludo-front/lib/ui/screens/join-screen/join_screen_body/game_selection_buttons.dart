import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'start_game_button.dart';

class GameSelectionButtons extends ConsumerWidget {
  final double boardSize;
  final dynamic handler;

  const GameSelectionButtons({
    super.key,
    required this.boardSize,
    required this.handler,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = GameLevel.values
        .where((level) => level != GameLevel.free)
        .toList();

    // کنترل حداکثر و حداقل ارتفاع کارت‌ها برای جلوگیری از رندر نامتقارن یا خطای اورفلو
    final containerHeight = (boardSize * 0.44).clamp(160.0, 240.0);
    final cardWidth = (boardSize * 0.72).clamp(240.0, 340.0);

    return RepaintBoundary(
      child: SizedBox(
        height: containerHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: levels.length,
          separatorBuilder: (context, index) =>
              SizedBox(width: boardSize * 0.04),
          itemBuilder: (context, index) {
            final level = levels[index];
            final isFourPlayerDisabled =
                (level == GameLevel.gold || level == GameLevel.vip);

            return Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF13141F).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: level.color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(alpha: 0.05),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // تقسیم فضا به صورت کاملاً ریسپانسیو داخلی
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "${level.displayName} Table",
                    style: TextStyle(
                      color: level.color,
                      fontSize: (boardSize * 0.045).clamp(14.0, 20.0),
                      // محدود کردن سایز فونت لول
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: level.color.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  if (isFourPlayerDisabled)
                    StartGameButton(
                      numberOfPlayers: 2,
                      entryFee: level.entryFee,
                      prizePool: level.prize2P,
                      themeColor: level.color,
                      onPressed: () => handler.handleGameSearch(
                        numberOfPlayers: 2,
                        gameType: GameType.global,
                        gameLevel: level,
                        boardSize: boardSize,
                      ),
                      boardSize: boardSize * 1.1,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: StartGameButton(
                            numberOfPlayers: 2,
                            entryFee: level.entryFee,
                            prizePool: level.prize2P,
                            themeColor: level.color,
                            onPressed: () => handler.handleGameSearch(
                              numberOfPlayers: 2,
                              gameType: GameType.global,
                              gameLevel: level,
                              boardSize: boardSize,
                            ),
                            boardSize: boardSize,
                          ),
                        ),
                        SizedBox(width: boardSize * 0.02),
                        Expanded(
                          child: StartGameButton(
                            numberOfPlayers: 4,
                            entryFee: level.entryFee,
                            prizePool: level.prize4P,
                            themeColor: level.color,
                            onPressed: () => handler.handleGameSearch(
                              numberOfPlayers: 4,
                              gameType: GameType.global,
                              gameLevel: level,
                              boardSize: boardSize,
                            ),
                            boardSize: boardSize,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
