import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/screens/board/board.dart';
import 'package:ludo/ui/screens/join-screen/join_screen.dart';
import 'package:ludo/ui/screens/leader_board_screen.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

import 'package:telegram_web_app/telegram_web_app.dart';

import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

@JS('onGameConnected')
external void onGameConnected();

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  bool _isLocalAssetsCached = false;
  bool _hasConnectionError = false;

  bool _isAlertOpen = false;

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
        final assetLottie = AssetLottie("assets/lotties/happy-dice.lottie");
        await assetLottie.load();
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
    gameController.onConnect = () {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      setState(() {
        _hasConnectionError = false;
      });
    };
    gameController.onReconnectionFailed = () {
      if (!mounted) return;

      setState(() {
        _hasConnectionError = true;
      });

      try {
        _safeCallOnGameConnected();
      } catch (e) {
        debugPrint("HTML Loader finish event error: $e");
      }
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onReconnectPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            showAnimatedDialog(
              context: context,
              child: ReconnectingAlert(),
              barrierDismissible: false,
            );

            gameController.updateState(
              gameController.currentGameState?.copyWith(
                connectionStatus: ConnectionStatus.reconnecting,
              ),
            );
            gameController.resumeReconnection();
          },
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
        gameController.connect(GameType.friendly, gameId);
      } else {
        gameController.connect(GameType.global, null);
      }
    } else {
      gameController.connect(GameType.global, null);
    }
  }

  // 🟢 متد کمکی برای فراخوانی امن جاوااسکریپت تلگرام
  void _safeCallOnGameConnected() {
    try {
      onGameConnected();
    } catch (e) {
      debugPrint("HTML Loader finish event error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameController = ref.read(gameControllerProvider.notifier);
    final currentStage = ref.watch(
      gameControllerProvider.select((state) => state?.gameStage),
    );

    if (_hasConnectionError) {
      return const Scaffold(
        backgroundColor: Color(0x0007070b),
        body: SizedBox.expand(),
      );
    }

    // لیسنر هوشمند وضعیت کانکشن بر اساس Stage بازی
    ref.listen<
      ConnectionStatus
    >(gameControllerProvider.select((state) => state!.connectionStatus), (
      previous,
      next,
    ) {
      debugPrint(
        "🔄 [Connection Event] Connection Status Changed: From $previous To $next",
      );

      // ۱. ورود به وضعیت تلاش برای اتصال مجدد (Reconnecting)
      if (next == ConnectionStatus.reconnecting) {
        if (!mounted) return;

        if (_isAlertOpen && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          _isAlertOpen = false;
        }
        _isAlertOpen = true;

        showAnimatedDialog(
          context: context,
          barrierDismissible: false,
          child: const ReconnectingAlert(),
        );
      }
      // ۲. شکست قطعی تمام تلاش‌ها و رفتن به وضعیت Disconnected
      else if (next == ConnectionStatus.disconnected) {
        if (_isAlertOpen && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          _isAlertOpen = false;
        }
        _isAlertOpen = true;

        showAnimatedDialog(
          context: context,
          barrierDismissible: false,
          child: ReconnectingFailedAlert(
            onReconnectPressed: () async {
              if (_isAlertOpen && Navigator.canPop(context)) {
                Navigator.of(context).pop();
                _isAlertOpen = false;
                gameController.updateState(
                  gameController.currentGameState?.copyWith(
                    connectionStatus: ConnectionStatus.reconnecting,
                  ),
                );
              }
              gameController.resumeReconnection();
            },
          ),
        );
      }
      // ۳. اتصال با موفقیت برقرار یا بازیابی شد
      else if (next == ConnectionStatus.connected) {
        if (_isAlertOpen && Navigator.canPop(context)) {
          Navigator.of(context).pop();
          _isAlertOpen = false;
        }
      }
    });

    if (currentStage == null ||
        currentStage == GameStage.connectionStage ||
        !_isLocalAssetsCached) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeCallOnGameConnected();
    });

    // 🚀 مدیریت هوشمند صفحات با استفاده از ValueKey برای شناسایی توسط AnimatedSwitcher
    Widget currentWidget;

    if (currentStage == GameStage.joinStage) {
      currentWidget = const JoinScreen(key: ValueKey('join_stage'));
    } else if (currentStage == GameStage.leaderBoard) {
      currentWidget = const LeaderboardScreen(
        key: ValueKey('leaderboard_stage'),
      );
    } else {
      ref.read(gameControllerProvider.notifier).stopMenuMusic();

      currentWidget = const Board(key: ValueKey('board_stage'));
    }

    // 🚀 رندر خروجی صفحات داخل لایه انیمیشن ترکیبی Fade & Scale
    return Scaffold(
      backgroundColor: const Color(0xFF536E7A),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: currentWidget,
      ),
    );
  }
}
