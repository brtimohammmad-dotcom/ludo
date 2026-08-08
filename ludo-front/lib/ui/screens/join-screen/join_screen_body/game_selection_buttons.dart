import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
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

    final double cardWidth = (boardSize * 0.58).clamp(270.0, 320.0);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.black,
                Colors.black,
                Colors.transparent,
              ],
              stops: [0.0, 0.08, 0.92, 1.0], // ایجاد محوشدگی نرم در دو طرف تخته چوبی
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: levels.map((level) {
                final isFourPlayerDisabled =
                (level == GameLevel.gold || level == GameLevel.vip);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: SizedBox(
                    width: cardWidth,
                    child: _LevelBox(
                      level: level,
                      boardSize: boardSize,
                      handler: handler,
                      showFourPlayer: !isFourPlayerDisabled,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// کارت لوکس چوبی متناسب با تخته منچ
class _LevelBox extends StatelessWidget {
  final GameLevel level;
  final double boardSize;
  final dynamic handler;
  final bool showFourPlayer;

  const _LevelBox({
    required this.level,
    required this.boardSize,
    required this.handler,
    required this.showFourPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // گرادیان چوب صیقل خورده گرم
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5C3613), // چوب دارچینی
            Color(0xFF3D210F), // چوب تیره سوخته
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.6), // حاشیه طلایی-چوبی
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر کارت
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: level.color,
                      boxShadow: [
                        BoxShadow(
                          color: level.color.withValues(alpha: 0.8),
                          blurRadius: 8,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr("${level.displayName} Table"),
                    style: TextStyle(
                      color: const Color(0xFFFFF8DC), // رنگ کرم چوبی خانی
                      fontSize: (boardSize * 0.048).clamp(16.0, 18.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // نشانگر سکه ورودی چوبی
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A160C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amberAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      level.entryFee == 0
                          ? context.tr('Free')
                          : context.num(level.entryFee),
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
          const SizedBox(height: 16),

          // دکمه‌های چوبی انتخاب بازی
          if (showFourPlayer) ...[
            StartGameButton(
              big: true,
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
            const SizedBox(height: 10),
            StartGameButton(
              big: true,
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
          ] else
            StartGameButton(
              big: true,
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
        ],
      ),
    );
  }
}