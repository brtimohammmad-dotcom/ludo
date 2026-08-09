import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/leader_board/leader_board.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/utils/painter.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardData = ref.watch(leaderboardDataProvider);
    final gameState = ref.read(gameControllerProvider);
    final playerData = gameState?.livePlayer;
    final playerCoin = playerData?.coin ?? 0;
    final playerName = playerData?.username ?? 'Guest';

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    final double base = boardSize * 0.85;

    const goldColor = Color(0xFFFFD700);
    const silverColor = Color(0xFFE2E8F0);
    const bronzeColor = Color(0xFFF59E0B);

    if (leaderboardData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A0F0A),
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: LudoBackgroundPainter()),
            ),
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5A2B)),
            ),
          ],
        ),
      );
    }

    final topPlayers = leaderboardData.topPlayers;
    final currentUserRank = leaderboardData.currentUserRank;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A),
      body: Stack(
        children: [
          // ۱. پس‌زمینه اصلی با پینتر
          Positioned.fill(
            child: CustomPaint(painter: LudoBackgroundPainter()),
          ),

          // ۲. قاب چوبی وسط صفحه
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                width: base * 1.1,
                height: base * 1.45,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A160C), // قهوه‌ای چوبی
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF8B5A2B), // حاشیه چوبی-طلایی
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // عنوان لیدربرد
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: base * 0.04),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF5C3A21),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('Leaderboard'),
                          style: TextStyle(
                            color: const Color(0xFFF5E6D3),
                            fontSize: base * 0.055,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // لیست رده‌بندی کاربران
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: base * 0.04,
                          vertical: base * 0.03,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: topPlayers.length,
                        itemBuilder: (context, index) {
                          final player = topPlayers[index];
                          final rank = index + 1;

                          Color rankColor = Colors.white30;
                          Widget rankWidget = Text(
                            '$rank',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: base * 0.04,
                            ),
                          );

                          if (rank == 1) {
                            rankColor = goldColor;
                            rankWidget = Icon(
                              Icons.emoji_events,
                              color: const Color(0xFF1A0F0A),
                              size: base * 0.05,
                            );
                          } else if (rank == 2) {
                            rankColor = silverColor;
                            rankWidget = Icon(
                              Icons.emoji_events,
                              color: const Color(0xFF1A0F0A),
                              size: base * 0.05,
                            );
                          } else if (rank == 3) {
                            rankColor = bronzeColor;
                            rankWidget = Icon(
                              Icons.emoji_events,
                              color: const Color(0xFF1A0F0A),
                              size: base * 0.05,
                            );
                          }

                          return Container(
                            margin: EdgeInsets.symmetric(vertical: base * 0.015),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B2013), // آیتم‌های چوبی تیره‌تر
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: rank <= 3
                                    ? rankColor.withValues(alpha: 0.5)
                                    : const Color(0xFF5C3A21),
                                width: rank <= 3 ? 1.5 : 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: base * 0.04,
                                vertical: base * 0.005,
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    color: goldColor,
                                    size: base * 0.045,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${player.coin}',
                                    style: TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: base * 0.038,
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                player.username,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: const Color(0xFFF5E6D3),
                                  fontSize: base * 0.038,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Container(
                                width: base * 0.09,
                                height: base * 0.09,
                                decoration: BoxDecoration(
                                  color: rank <= 3
                                      ? rankColor
                                      : const Color(0xFF2A160C),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: rankWidget,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // بخش پایین: کارت کاربر جاری و دکمه خانه
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1F1008),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // مشخصات کاربر جاری
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: base * 0.03,
                              horizontal: base * 0.04,
                            ),
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.monetization_on,
                                      color: goldColor,
                                      size: base * 0.045,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$playerCoin',
                                      style: TextStyle(
                                        color: goldColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: base * 0.038,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  playerName,
                                  style: TextStyle(
                                    color: const Color(0xFFF5E6D3),
                                    fontSize: base * 0.038,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: base * 0.03),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: base * 0.025,
                                    vertical: base * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.amber.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    '#$currentUserRank',
                                    style: TextStyle(
                                      color: goldColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: base * 0.034,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // دکمه بازگشت (خانه)
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(gameControllerProvider.notifier)
                                  .updateState(
                                gameState?.copyWith(
                                    gameStage: GameStage.joinStage),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.all(base * 0.025),
                              padding: EdgeInsets.symmetric(
                                  vertical: base * 0.03),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr('Home'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: base * 0.04,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: base * 0.045,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}