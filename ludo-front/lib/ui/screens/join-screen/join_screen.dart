import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/screens/join-screen/floating_bottom_menu.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/coin_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/game_selection_buttons.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/user_profile_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_handler.dart';
import 'package:ludo/ui/screens/join-screen/utils.dart';
import 'package:ludo/ui/utils/alerts/freinds_dialog.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/waiting_for_game_alert.dart';
import 'package:ludo/ui/utils/painter.dart';
import 'package:lottie/lottie.dart';

import 'package:web/web.dart' as web;

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  late JoinScreenHandler _handler;

  /// 🎯 بررسی اینکه کاربر روی دستگاه موبایل (iOS / Android) است یا خیر
  bool get _isMobileDevice {
    if (!kIsWeb) return false;
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    return userAgent.contains('android') ||
        userAgent.contains('iphone') ||
        userAgent.contains('ipad');
  }

  @override
  void initState() {
    super.initState();
    ref.read(gameControllerProvider.notifier).playMenuMusic();
    _handler = JoinScreenHandler(
      context: context,
      gameController: ref.read(gameControllerProvider.notifier),
      audioService: ref.read(audioServiceProvider),
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
    final gameState = ref.watch(gameControllerProvider);
    final currentPlayer = gameState?.livePlayer;

    // 📱 اعمال ۳۵ پیکسل پدینگ فقط در صورتی که سیستم‌عامل گوشی موبایل باشد
    final double telegramTopPadding = _isMobileDevice ? 35.0 : 0.0;

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
      bottomNavigationBar: RepaintBoundary(
        child: FloatingBottomMenu(
          boardSize: layout.boardSize,
          onFriendsTap: () =>
              showFriendsPlayDialog(context, layout.boardSize, _handler),
          onLeaderboardTap: () {
            ref.read(gameControllerProvider.notifier).getLeaderBoardList();
            ref
                .read(globalLoadingProvider.notifier)
                .start('leader_board_loading');
          },
          onShopTap: () {},
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // پس‌زمینه
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: LudoBackgroundPainter()),
            ),
          ),
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  // 🎯 فاصله بالا فقط در سیستم‌عامل‌های موبایل
                  SizedBox(height: telegramTopPadding),
                  SizedBox(height: layout.screenHeight * 0.08),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDiceSection(layout.diceSize),
                        const Spacer(flex: 1),
                        Flexible(
                          flex: 5,
                          child: GameSelectionButtons(
                            boardSize: layout.boardSize,
                            handler: _handler,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: layout.screenHeight * 0.14),
                ],
              ),
            ),
          ),
          // 🪙 موقعیت سکه
          Positioned(
            top: MediaQuery.of(context).padding.top + 16 + telegramTopPadding,
            left: 16,
            child: RepaintBoundary(child: CoinBox(boardSize: layout.boardSize)),
          ),
          // 👤 موقعیت پروفایل
          Positioned(
            top: MediaQuery.of(context).padding.top + 16 + telegramTopPadding,
            right: 16,
            child: RepaintBoundary(
              child: UserProfileBox(
                player: currentPlayer,
                boardSize: layout.boardSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceSection(double diceSize) {
    return Flexible(
      flex: 6,
      child: Center(
        child: RepaintBoundary(
          child: Lottie.asset(
            "assets/lotties/happy-dice.lottie",
            width: diceSize * 2,
            height: diceSize * 2,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}