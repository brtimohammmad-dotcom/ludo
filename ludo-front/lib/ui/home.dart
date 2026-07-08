import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/audio_service.dart';
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
  bool _isLocalAssetsCached = false;
  bool _hasConnectionError = false; // 🟢 اضافه کردن فلگ وضعیت خطا

  @override
  void initState() {
    super.initState();
    _initGameAndAssets();
  }

  Future<void> _initGameAndAssets() async {
    final gameController = ref.read(gameControllerProvider.notifier);

    _establishConnection(gameController);
    _setupControllerCallbacks(gameController);

    final audio = ref.read(audioServiceProvider);
    await audio.initAudioCache([
      'assets/audio/sound-effect/current_turn_sound.wav',
      'assets/audio/sound-effect/dice_rolling.wav',
      'assets/audio/sound-effect/exit_button_sound.wav',
      'assets/audio/sound-effect/friend_button_sound.wav',
      'assets/audio/sound-effect/kick_token.wav',
      'assets/audio/sound-effect/move_token.wav',
      'assets/audio/sound-effect/target_token.wav',
      'assets/audio/sound-effect/winner_sound.wav',
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await precacheImage(const AssetImage("assets/webp/happy-dice.webp"), context);
      } catch (e) {
        debugPrint("🖼️ Error caching image: $e");
      }

      if (mounted) {
        setState(() {
          _isLocalAssetsCached = true;
        });
      }
    });
  }

  void _setupControllerCallbacks(GameController gameController) {
    gameController.onReconnectionFailed = () {
      if (!mounted) return;

      // 🟢 وضعیت خطا را فعال می‌کنیم تا متد build اجازه رندر صفحه را بدهد
      setState(() {
        _hasConnectionError = true;
      });

      // 🟢 لودر تلگرام را مخفی می‌کنیم تا آلرت فلاتر دیده شود
      try {
        onGameConnected();
      } catch (e) {
        debugPrint("HTML Loader finish event error: $e");
      }

      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            setState(() {
              _hasConnectionError = false; // ریست کردن وضعیت خطا هنگام تلاش مجدد
            });
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

    if (_hasConnectionError) {
      return const Scaffold(
        backgroundColor: Color(0x0007070b), // هماهنگ با بک‌گراند وب
        body: SizedBox.expand(),
      );
    }

    // شرط لودینگ اولیه معمولی
    if (currentStage == null || currentStage == GameStage.connectionStage || !_isLocalAssetsCached) {
      return const Scaffold(backgroundColor: Colors.transparent, body: SizedBox.shrink());
    }

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