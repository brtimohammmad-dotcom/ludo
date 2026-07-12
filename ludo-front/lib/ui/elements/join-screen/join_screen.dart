import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/elements/join-screen/floating_bottom_menu.dart';
import 'package:ludo/ui/elements/join-screen/join_screen_body/coin_box.dart';
import 'package:ludo/ui/elements/join-screen/join_screen_body/game_selection_buttons.dart';
import 'package:ludo/ui/elements/join-screen/join_screen_handler.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/waiting_for_game_alert.dart';

enum GameMode { global, friendly }

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
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // پس‌زمینه و محتوای اصلی دکمه‌ها
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade500,
                  Colors.blueGrey,
                  Colors.blueGrey,
                  Colors.blueGrey.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/webp/happy-dice.webp",
                    width: boardSize * 0.6,
                    height: boardSize * 0.6,
                    fit: BoxFit.cover,
                  ),
                  GameSelectionButtons(boardSize: boardSize, handler: _handler),
                ],
              ),
            ),
          ),

          CoinBox(boardSize: boardSize),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: FloatingBottomMenu(
        boardSize: boardSize,
        onSettingsTap: () {
          print("تنظیمات لمس شد");
        },
        onLeaderboardTap: () {
          print("لیدربورد لمس شد");
        },
        onShopTap: () {
          print("فروشگاه لمس شد");
        },
      ),
    );
  }
}
