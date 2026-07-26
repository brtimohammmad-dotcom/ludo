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

    return RepaintBoundary(
      // 🎭 ایجاد ماسک محوشدگی (Fade Mask) در بالا و پایین اسکرول
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent, // محو شدن از بالا
              Colors.black,       // شفافیت کامل در مرکز
              Colors.black,       // شفافیت کامل در مرکز
              Colors.transparent, // محو و تاریک شدن در پایین (Fade Out)
            ],
            stops: [0.0, 0.08, 0.85, 1.0], // تنظیم میزان تاریک شدن انتهای اسکرول
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          itemCount: levels.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final level = levels[index];
            final isFourPlayerDisabled =
            (level == GameLevel.gold || level == GameLevel.vip);

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    level.color.withValues(alpha: 0.12),
                    const Color(0xFF1E293B).withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: level.color.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: level.color.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header کارت
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: level.color,
                              boxShadow: [
                                BoxShadow(
                                  color: level.color,
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${level.displayName} Table",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (boardSize * 0.042).clamp(14.0, 17.0),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amberAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              level.entryFee == 0 ? "Free" : "${level.entryFee}",
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // دکمه‌های بازی
                  if (isFourPlayerDisabled)
                    StartGameButton(
                      numberOfPlayers: 2,
                      prizePool: level.prize2P,
                      themeColor: level.color,
                      onPressed: () => handler.handleGameSearch(
                        numberOfPlayers: 2,
                        gameType: GameType.global,
                        gameLevel: level,
                        boardSize: boardSize,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: StartGameButton(
                            numberOfPlayers: 2,
                            prizePool: level.prize2P,
                            themeColor: level.color,
                            onPressed: () => handler.handleGameSearch(
                              numberOfPlayers: 2,
                              gameType: GameType.global,
                              gameLevel: level,
                              boardSize: boardSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StartGameButton(
                            numberOfPlayers: 4,
                            prizePool: level.prize4P,
                            themeColor: level.color,
                            onPressed: () => handler.handleGameSearch(
                              numberOfPlayers: 4,
                              gameType: GameType.global,
                              gameLevel: level,
                              boardSize: boardSize,
                            ),
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