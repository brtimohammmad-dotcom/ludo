import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/screens/join-screen/floating_bottom_menu.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/coin_box.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/game_selection_buttons.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_handler.dart';
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

  void showWaitingDialog(double boardSize) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: WaitingForGameAlert(boardSize: boardSize),
    );
  }

  @override
  void initState() {
    super.initState();

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

// ... کدهای قبلی و ایمپورت‌ها بدون تغییر باقی می‌مانند ...

// ... کدهای قبلی و ایمپورت‌ها بدون تغییر باقی می‌مانند ...

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // محاسبه منعطف‌تر سایز پایه
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.8);

    ref.listen<bool>(
      globalLoadingProvider.select((s) => s.contains("waiting_for_game")),
          (previous, next) {
        if (next == true) {
          showWaitingDialog(boardSize);
        } else if (previous == true && next == false) {
          Navigator.of(context).pop();
        }
      },
    );

    // محاسبه سایز تاس با در نظر گرفتن یک سقف حداکثری (تا در وب خیلی بزرگ نشود)
    final diceSize = (boardSize * 0.4).clamp(120.0, 220.0);

    return Scaffold(
      backgroundColor: const Color(0xFF07070B),
      resizeToAvoidBottomInset: false,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ۱. پس‌زمینه
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LudoBackgroundPainter(),
              ),
            ),
          ),

          // ۲. محتوای اصلی
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  // ایجاد فاصله منعطف از بالا متناسب با ارتفاع صفحه
                  SizedBox(height: screenHeight * 0.08),

                  // بخش وسط به صورت کاملاً ریسپانسیو و منعطف
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // اشغال حداقل فضای ممکن
                      children: [
                        // بخش تاس
                        Flexible(
                          flex: 3,
                          child: Center(
                            child: RepaintBoundary(
                              child: SizedBox(
                                width: diceSize,
                                height: diceSize,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: diceSize,
                                      height: diceSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.amber.withValues(alpha: 0.15),
                                            Colors.amber.withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      "assets/webp/happy-dice.webp",
                                      width: diceSize * 0.8,
                                      height: diceSize * 0.8,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // فاصله متناسب و منعطف
                        const Spacer(flex: 1),

                        // بخش دکمه‌های افقی
                        Flexible(
                          flex: 5,
                          child: GameSelectionButtons(
                            boardSize: boardSize,
                            handler: _handler,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ایجاد فضای خالی پایین صفحه متناسب با منوی شناور
                  SizedBox(height: screenHeight * 0.14),
                ],
              ),
            ),
          ),

          // باکس سکه بالا سمت چپ
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: RepaintBoundary(
              child: CoinBox(boardSize: boardSize),
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: RepaintBoundary(
        child: FloatingBottomMenu(
          boardSize: boardSize,
          onFriendsTap: () {
            showFriendsPlayDialog(context, boardSize, _handler);
          },
          onLeaderboardTap: () {
            ref.read(gameControllerProvider.notifier).getLeaderBoardList();
            ref.read(globalLoadingProvider.notifier).start('leader_board_loading');
          },
          onShopTap: () {},
        ),
      ),
    );
  }
// ...
}