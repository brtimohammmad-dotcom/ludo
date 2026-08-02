import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/asset_loader_service.dart';
import 'package:ludo/ui/screens/board/board.dart';
import 'package:ludo/ui/screens/join-screen/join_screen.dart';
import 'package:ludo/ui/screens/leader_board_screen.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_alert.dart';
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

    // پیش‌لود از طریق سرویس جدید
    await ref.read(assetLoaderServiceProvider).preloadAll();

    if (mounted) {
      setState(() {
        _isLocalAssetsCached = true;
      });
    }
  }

  void _establishConnection(GameController gameController) {
    if (!mounted) return;
    gameController.connect();
  }

  void _setupControllerCallbacks(GameController gameController) {
    gameController.onConnect = () {
      if (!mounted) return;
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
            if (!mounted) return;

            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            showAnimatedDialog(
              context: context,
              child: const ReconnectingAlert(),
              barrierDismissible: false,
            );

            // 🟢 خواندن ایمن و تازه از ref
            final controller = ref.read(gameControllerProvider.notifier);
            controller.updateState(
              controller.currentGameState?.copyWith(
                connectionStatus: ConnectionStatus.reconnecting,
              ),
            );
            controller.resumeReconnection();
          },
        ),
      );
    };
  }

  void _safeCallOnGameConnected() {
    try {
      onGameConnected();
    } catch (e) {
      debugPrint("HTML Loader finish event error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 ۱. ثبت همه Listenerها در بالاترین سطح build (بدون هیچ Return قبل از آن‌ها)
    ref.listen<ConnectionStatus>(
      gameControllerProvider.select((state) => state!.connectionStatus),
          (previous, next) {
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
          if (!mounted) return;

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
                if (!mounted) return;

                if (_isAlertOpen && Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                  _isAlertOpen = false;
                }

                final controller = ref.read(gameControllerProvider.notifier);
                controller.updateState(
                  controller.currentGameState?.copyWith(
                    connectionStatus: ConnectionStatus.reconnecting,
                  ),
                );
                controller.resumeReconnection();
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
      },
    );

    // مدیریت موزیک منو
    ref.listen<GameStage?>(
      gameControllerProvider.select((state) => state?.gameStage),
          (previous, next) {
        if (next != null &&
            next != GameStage.joinStage &&
            next != GameStage.leaderBoard) {
          ref.read(gameControllerProvider.notifier).stopMenuMusic();
        }
      },
    );

    // 🟢 ۲. لیسن شدن Stage برای زنده نگه داشتن و Listen به پرووایدر اصلی
    final currentStage = ref.watch(
      gameControllerProvider.select((state) => state?.gameStage),
    );

    // 🟢 ۳. حالا که Listenerها و Watch ثبت شدند، نوبت بررسی شرط خطا است
    if (_hasConnectionError) {
      return const Scaffold(
        backgroundColor: Color(0x0007070b),
        body: SizedBox.expand(),
      );
    }

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
        child: _buildStageScreen(currentStage),
      ),
    );
  }

  Widget _buildStageScreen(GameStage stage) {
    switch (stage) {
      case GameStage.joinStage:
        return const JoinScreen(key: ValueKey('join_stage'));
      case GameStage.leaderBoard:
        return const LeaderboardScreen(key: ValueKey('leaderboard_stage'));
      default:
        return const Board(key: ValueKey('board_stage'));
    }
  }
}