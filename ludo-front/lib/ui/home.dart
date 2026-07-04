import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/ui/elements/board/board.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

@JS('onGameConnected')
external void onGameConnected();

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  @override
  void initState() {
    super.initState();
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
      gameController.connect(GameMode.global, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = ref.watch(
      gameControllerProvider.select((state) => state?.gameStage),
    );

    // 🟢 وضعیت اول: شیشه‌ای ماندن کامل تا زمان دریافت استیت معتبر از سرور
    if (currentStage == null || currentStage == GameStage.connectionStage) {
      return const SizedBox.shrink();
    }
    // حذف انیمیشن HTML درست پس از رندر شدن اولین فریم استیج جدید
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        onGameConnected();
      } catch (e) {
        debugPrint("HTML Loader finish event error: $e");
      }
    });

    if (currentStage == GameStage.joinStage) {
      return const JoinScreen();
    }

    return const Board();
  }
}
