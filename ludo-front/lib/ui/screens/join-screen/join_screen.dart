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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

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

    return Scaffold(
      backgroundColor: const Color(0xFF07070B),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // ⚡ ۱. ایزوله کردن کامل پس‌زمینه Canvas با RepaintBoundary
          Positioned.fill(
            child:  RepaintBoundary(
              child: CustomPaint(
                painter: LudoBackgroundPainter(),
              ),
            ),
          ),

          // محتوای اصلی روی بک‌گراند
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.03),

                    // ⚡ ۲. ایزوله کردن افکت پالس تاس
                    RepaintBoundary(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.1),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          "assets/webp/happy-dice.webp",
                          width: boardSize * 0.55,
                          height: boardSize * 0.55,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // ⚡ ۳. بخش دکمه‌های انتخاب لول بازی
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GameSelectionButtons(
                        boardSize: boardSize,
                        handler: _handler,
                      ),
                    ),

                    // فاصله انتهایی کافی برای اینکه دکمه‌ها زیر منوی معلق پایین پنهان نشوند
                    SizedBox(height: screenHeight * 0.18),
                  ],
                ),
              ),
            ),
          ),

          // ✅ حل مشکل کرش: دیگر پیچیدن درون Positioned اضافی لازم نیست؛
          // چون CoinBox خودش در سطح اول کدهایش با Positioned پیاده‌سازی شده است.
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
            debugPrint("لیدربورد لمس شد");
            ref.read(gameControllerProvider.notifier).getLeaderBoardList();
            ref.read(globalLoadingProvider.notifier).start('leader_board_loading');
          },
          onShopTap: () {
            debugPrint("فروشگاه لمس شد");
          },
        ),
      ),
    );
  }
}