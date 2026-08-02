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

    final double base = boardSize * 0.85; // پایه مقیاس‌دهی منسجم با کل پروژه

    // گرادینت‌ها و رنگ‌های اختصاصی لیدربرد منطبق با تم جدید
    const goldColor = Color(0xFFFFD700);
    const silverColor = Color(0xFFE2E8F0);
    const bronzeColor = Color(0xFFF59E0B);

    if (leaderboardData == null) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: LudoBackgroundPainter()),
            ),
            const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            ),
          ],
        ),
      );
    }

    final topPlayers = leaderboardData.topPlayers;
    final currentUserRank = leaderboardData.currentUserRank;

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 ۱. پس‌زمینه عمیق کهکشانی مشترک با صفحه اصلی
          Positioned.fill(child: CustomPaint(painter: LudoBackgroundPainter())),

          // ۲. محتوا
          SafeArea(
            child: Column(
              children: [
                // هدر صفحه با شیشه نئونی ظریف و افکت درخشش
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: base * 0.04),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.amber.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      context.tr('Leaderboard').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: base * 0.055,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.5,
                        shadows: [
                          Shadow(
                            color: Colors.amber.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // لیست کاربران برتر با استایل کارت‌های شیک و لبه‌های رنگی
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      base * 0.05,
                      base * 0.04,
                      base * 0.05,
                      base * 0.42, // فاصله کافی برای شناور نماندن روی بخش پایین
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
                          color: const Color(0xFF0F172A),
                          size: base * 0.05,
                        );
                      } else if (rank == 2) {
                        rankColor = silverColor;
                        rankWidget = Icon(
                          Icons.emoji_events,
                          color: const Color(0xFF0F172A),
                          size: base * 0.05,
                        );
                      } else if (rank == 3) {
                        rankColor = bronzeColor;
                        rankWidget = Icon(
                          Icons.emoji_events,
                          color: const Color(0xFF0F172A),
                          size: base * 0.05,
                        );
                      }

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: base * 0.015),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(
                            alpha: 0.75,
                          ), // تم تاریک نیمه شفاف شیشه‌ای
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: rank <= 3
                                ? rankColor.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.08),
                            width: rank <= 3 ? 1.5 : 1,
                          ),
                          boxShadow: rank <= 3
                              ? [
                                  BoxShadow(
                                    color: rankColor.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: base * 0.04,
                            vertical: base * 0.01,
                          ),
                          leading: Container(
                            width: base * 0.09,
                            height: base * 0.09,
                            decoration: BoxDecoration(
                              color: rank <= 3
                                  ? rankColor
                                  : Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              boxShadow: rank <= 3
                                  ? [
                                      BoxShadow(
                                        color: rankColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: rankWidget,
                          ),
                          title: Text(
                            player.username,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: base * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${player.coin}',
                                style: TextStyle(
                                  color: goldColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: base * 0.038,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.monetization_on,
                                color: goldColor,
                                size: base * 0.045,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ۳. کنترلر و کارت مشخصات کاربر به اضافه دکمه Home سبز نئونی و درخشان
          Positioned(
            bottom: base * 0.04,
            left: base * 0.05,
            right: base * 0.05,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // کارت مشخصات کاربر شیشه‌ای (Frosted Glass Effect)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 15,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: base * 0.035,
                    horizontal: base * 0.04,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: base * 0.03,
                          vertical: base * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#$currentUserRank',
                          style: TextStyle(
                            color: goldColor,
                            fontWeight: FontWeight.w900,
                            fontSize: base * 0.034,
                          ),
                        ),
                      ),
                      SizedBox(width: base * 0.03),
                      Text(
                        playerName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: base * 0.038,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '$playerCoin',
                            style: TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.w900,
                              fontSize: base * 0.038,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.monetization_on,
                            color: goldColor,
                            size: base * 0.045,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // دکمه بازگشت به منو سبز نئونیِ هماهنگ با دکمه دیالوگ برنده بازی
                GestureDetector(
                  onTap: () {
                    ref
                        .read(gameControllerProvider.notifier)
                        .updateState(
                          gameState?.copyWith(gameStage: GameStage.joinStage),
                        );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: base * 0.035),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF22C55E), // سبز نئونی
                          Color(0xFF15803D),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.white,
                          size: base * 0.045,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr(  'Home'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: base * 0.038,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
