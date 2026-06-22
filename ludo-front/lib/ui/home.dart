import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/elements/board/board.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
    // 🟢 اجرای منطق اتصال بلافاصله پس از رندر شدن اولین فریم برای داشتن رفرنس صحیح از ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameController = ref.read(gameControllerProvider.notifier);
      _establishConnection(gameController);
      _setupControllerCallbacks(gameController);
    });
  }

  void _setupControllerCallbacks(GameController gameController) {
    gameController.onReconnectionFailed = () {
      if (!mounted) return;

      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            gameController.gameRepository.dataSource.resumeReconnection();
          },
          textButton: "Reconnect",
        ),
      );
    };

    gameController.gameRepository.dataSource.onDisconnectCallback = () {
      if (mounted && TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert('Connection lost. Reconnecting...');
      }
    };
  }

  void _establishConnection(GameController gameController) {
    if (!mounted) return;

    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      TelegramWebApp.instance.expand();

      final startParam = TelegramWebApp.instance.initDataUnsafe?.startParam;
      if (startParam != null && startParam.startsWith("game_")) {
        final gameId = startParam.replaceAll("game_", "");
        gameController.connect(GameMode.friendly, gameId);
      } else {
        gameController.connect(GameMode.global, null);
      }
    } else {
      // برای تست راحت‌تر در مرورگر دسکتاپ یا حالت وب معمولی خارج از تلگرام
      gameController.connect(GameMode.global, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight ? screenWidth : screenHeight * 0.86);

    // 🟢 ۱. تماشای وضعیت فضا (Stage) به صورت بهینه
    final currentStage = ref.watch(
      gameControllerProvider.select((state) => state?.gameStage),
    );

    // وضعیت اول: استیت کلاً وجود ندارد یا هنوز در مرحله اتصال اولیه هستیم
    if (currentStage == null || currentStage == GameStage.connectionStage) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.fourRotatingDots(
                color: Colors.lightGreenAccent,
                size: boardSize * 0.2,
              ),
              SizedBox(height: boardSize * 0.01),
              const Text(
                'Connecting to Server...',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.lightGreenAccent,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(-2, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // وضعیت دوم: هدایت به منوی اصلی بازی
    if (currentStage == GameStage.joinStage) {
      return const JoinScreen();
    }

    // وضعیت سوم: کاربر داخل بازی فعال است
    return const Board();
  }
}
