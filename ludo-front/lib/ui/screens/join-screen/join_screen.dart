import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/floating_bottom_menu.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/daily_reward_and_coin_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/game_selection_buttons.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/setting_icon.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/user_profile_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_handler.dart';
import 'package:ludo/ui/screens/join-screen/utils.dart';
import 'package:ludo/ui/utils/alerts/freinds_dialog.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/waiting_for_game_alert.dart';
import 'package:ludo/ui/utils/painter.dart';

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  late JoinScreenHandler _handler;

  @override
  void initState() {
    super.initState();
    ref.read(gameControllerProvider.notifier).playMenuMusic();
    _handler = JoinScreenHandler(
      context: context,
      gameController: ref.read(gameControllerProvider.notifier),
      audioService: ref.read(audioServiceProvider.notifier),
      isMounted: () => mounted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handler.setupControllerCallbacks();
    });
  }

  void _showWaitingDialog(double boardSize) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: WaitingForGameAlert(boardSize: boardSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = JoinScreenLayout(context);
    final gameState = ref.read(gameControllerProvider);
    final currentPlayer = gameState?.livePlayer;

    ref.listen<bool>(
      globalLoadingProvider.select((s) => s.contains("waiting_for_game")),
      (previous, next) {
        if (next == true) {
          _showWaitingDialog(layout.boardSize);
        } else if (previous == true && next == false) {
          Navigator.of(context).pop();
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: Stack(
        children: [
          // ۱. پس‌زمینه
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: LudoBackgroundPainter()),
            ),
          ),

          // ۲. محتوای اصلی (هدر + کارت‌های لول)
          SafeArea(
            top: true,
            bottom: false, // اجازه میده لیست تا پایین‌ترین نقطه بره
            child: Column(
              children: [
                const SizedBox(height: 8),

                // 👑 عنوان بازی LUDO RUSH
                Center(
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      'LUDO RUSH',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ➖ خط جداکننده زیر عنوان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    thickness: 1,
                    height: 1,
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // سکه‌باکس
                        RepaintBoundary(
                          child: DailyRewardAndCoinBox(boardSize: layout.boardSize),
                        ),

                        // پروفایل
                        RepaintBoundary(
                          child: Row(
                            children: [
                              SettingIcon(),
                              const SizedBox(width: 6),
                              UserProfileBox(
                                player: currentPlayer,
                                boardSize: layout.boardSize,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 🎮 ۳. لیست لول‌ها (پرکننده کامل تمام فضای عمودی تا انتهای صفحه)
                Expanded(
                  child: GameSelectionButtons(
                    boardSize: layout.boardSize,
                    handler: _handler,
                  ),
                ),
              ],
            ),
          ),

          // ۳. منوی شناور پایین روی کل محتوا (Floating Overlay)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: RepaintBoundary(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: FloatingBottomMenu(
                  boardSize: layout.boardSize,
                  onFriendsTap: () => showFriendsPlayDialog(
                    context,
                    layout.boardSize,
                    _handler,
                  ),
                  onLeaderboardTap: () {
                    ref
                        .read(gameControllerProvider.notifier)
                        .getLeaderBoardList();
                    ref
                        .read(globalLoadingProvider.notifier)
                        .start('leader_board_loading');
                  },
                  onShopTap: () {
                    ref
                        .read(gameControllerProvider.notifier)
                        .updateState(
                          gameState?.copyWith(gameStage: GameStage.shopScreen),
                        );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
