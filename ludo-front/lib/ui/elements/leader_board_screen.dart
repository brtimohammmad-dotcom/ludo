import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/leader_board/leader_board.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // خواندن دیتای لیدربرد از پرووایدر ریورپاد
    final leaderboardData = ref.watch(leaderboardDataProvider);
    final gameState = ref.read(gameControllerProvider);
    final playerData = gameState?.livePlayer;
    final playerCoin = playerData?.coin ?? 0;
    final playerName = playerData?.username ?? 'Guest';

    // رنگ‌های هماهنگ با تم بازی شما
    const backgroundColor = Color(0xFF536E7A);
    const cardColor = Color(0xFF37474F);
    const accentColor = Color(0xFF1ABC9C);
    const goldColor = Color(0xFFFFD700);
    const silverColor = Color(0xFFB0BEC5);
    const bronzeColor = Color(0xFFCA7D17);

    // مدیریت حالت اضطراری (اگر به هر دلیلی دیتا هنوز نرسیده بود)
    if (leaderboardData == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: accentColor)),
      );
    }

    final topPlayers = leaderboardData.topPlayers;
    final currentUserRank = leaderboardData.currentUserRank;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // هدر و لیست اصلی بازیکنان
            Column(
              children: [
                // ۱. هدر صفحه (عنوان کاملاً در مرکز)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  child: Center(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Divider(color: Colors.white10, height: 1),

                // ۲. لیست اسکرول‌شونده ۱۰ نفر برتر
                Expanded(
                  child: ListView.builder(
                    // پدینگ پایین را بیشتر کردیم (۱60) تا لیست کاملاً بالاتر از باکس بزرگ شناور جدید بایستد
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
                    itemCount: topPlayers.length,
                    itemBuilder: (context, index) {
                      final player = topPlayers[index];
                      final rank = index + 1;

                      Color rankColor = Colors.white24;
                      Widget rankWidget = Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );

                      if (rank == 1) {
                        rankColor = goldColor;
                        rankWidget = const Icon(
                          Icons.emoji_events,
                          color: Colors.black,
                          size: 22,
                        );
                      } else if (rank == 2) {
                        rankColor = silverColor;
                        rankWidget = const Icon(
                          Icons.emoji_events,
                          color: Colors.black,
                          size: 22,
                        );
                      } else if (rank == 3) {
                        rankColor = bronzeColor;
                        rankWidget = const Icon(
                          Icons.emoji_events,
                          color: Colors.black,
                          size: 22,
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: cardColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: rank <= 3
                                ? rankColor.withValues(alpha: 0.5)
                                : Colors.white10,
                            width: rank <= 3 ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: rankColor,
                              shape: BoxShape.circle,
                              boxShadow: rank <= 3
                                  ? [
                                      BoxShadow(
                                        color: rankColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: rankWidget,
                          ),
                          title: Text(
                            player.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${player.coin}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.monetization_on,
                                color: Color(0xFFFFD700),
                                size: 20,
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

            // ۳. باکس شناور مشخصات کاربر + دکمه Home در پایین صفحه
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // کارت اطلاعات کاربر
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        // رتبه کاربر
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: accentColor, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '#$currentUserRank',
                            style: const TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // نام بازیکن فعلی
                        Text(
                          playerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // سکه بازیکن فعلی
                        Row(
                          children: [
                            Text(
                              '$playerCoin',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.monetization_on,
                              color: Color(0xFFFFD700),
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // دکمه Home چسبیده زیر کارت مشخصات
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(20),
                          ),
                        ),
                      ),
                      onPressed: () {
                        // بازگشت به منوی اصلی با تغییر استیج
                        ref
                            .read(gameControllerProvider.notifier)
                            .updateState(
                              gameState?.copyWith(
                                gameStage: GameStage.joinStage,
                              ),
                            );
                      },
                      icon: const Icon(Icons.home, size: 22),
                      label: const Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
