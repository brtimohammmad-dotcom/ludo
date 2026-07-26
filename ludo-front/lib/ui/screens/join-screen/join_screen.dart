import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/floating_bottom_menu.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/coin_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/game_selection_buttons.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/ludo_rush_box.dart';
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

    // 📱 فاصله بالای تلگرام فقط برای سیستم‌عامل‌های موبایل
    final double telegramTopPadding = _isMobileDevice ? 35.0 : 0.0;

    // 📍 فاصله هم‌تراز هدر برای سکه و پروفایل
    final double headerTopPadding =
        MediaQuery.of(context).padding.top + 8 + telegramTopPadding;

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
          // ۱. پس‌زمینه
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(painter: LudoBackgroundPainter()),
            ),
          ),

          // ۲. بدنه محتوا
          SafeArea(
            child: SizedBox.expand(
              child: Column(
                children: [
                  SizedBox(height: telegramTopPadding + 55),
                  Expanded(
                    child: Column(
                      children: [
                        // تاس فشرده و متناسب
                        Flexible(
                          flex: 3,
                          child: _buildDiceSection(layout.diceSize),
                        ),
                        const SizedBox(height: 6),
                        // لیست کارت‌های لول‌بندی با فضای اختصاصی کافی
                        Expanded(
                          flex: 8,
                          child: GameSelectionButtons(
                            boardSize: layout.boardSize,
                            handler: _handler,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: layout.screenHeight * 0.1),
                ],
              ),
            ),
          ),

          // 👑 ۳. عنوان بازی در مرکز هدر
          LudoRushBox(telegramTopPadding: telegramTopPadding),

          // 🪙 ۴. موقعیت سکه و هدیه (هم‌تراز در هدر - سمت چپ)
          Positioned(
            top: headerTopPadding,
            left: 12,
            child: RepaintBoundary(child: CoinBox(boardSize: layout.boardSize)),
          ),

          // 👤 ۵. موقعیت پروفایل (هم‌تراز در هدر - سمت راست)
          Positioned(
            top: headerTopPadding,
            right: 12,
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
    final double baseSize = (diceSize * 0.85).clamp(80.0, 130.0);

    return Center(
      child: RepaintBoundary(
        child: SizedBox(
          width: baseSize * 1.1,
          height: baseSize * 1.1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ۱. هاله نورانی ظریف
              Container(
                width: baseSize * 0.95,
                height: baseSize * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.22),
                      const Color(0xFF3B82F6).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // ۲. سایه زیر تاس
              Positioned(
                bottom: 2,
                child: Container(
                  width: baseSize * 0.45,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.elliptical(baseSize * 0.45, 6)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // ۳. تاس اصلی
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -3 * (1 - (value - 0.5).abs() * 2)),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.01),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Lottie.asset(
                    "assets/lotties/happy-dice.lottie",
                    width: baseSize,
                    height: baseSize,
                    fit: BoxFit.contain,
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