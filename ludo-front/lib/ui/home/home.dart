import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/asset_loader_service.dart';
import 'package:ludo/ui/home/connection_dialog_manager.dart';
import 'package:ludo/ui/screens/board/board.dart';
import 'package:ludo/ui/screens/join-screen/join_screen.dart';
import 'package:ludo/ui/screens/leader_board_screen.dart';

@JS('onGameConnected')
external void onGameConnected();

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  bool _isAssetsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initGameAndCallbacks();
  }

  Future<void> _initGameAndCallbacks() async {
    final controller = ref.read(gameControllerProvider.notifier);

    // ۱. تنظیم کالبک‌ها قبل از شروع اتصال (برای زمانی که هنوز توی صفحه HTML هستیم)
    _setupControllerCallbacks(controller);

    // ۲. شروع اتصال
    controller.connect();

    // ۳. لود Assetها
    await ref.read(assetLoaderServiceProvider).preloadAll();

    if (mounted) {
      setState(() => _isAssetsLoaded = true);
    }
  }

  /// 🟢 تنظیم کالبک‌های کنترلر برای زمان قطعی در صفحه HTML
  void _setupControllerCallbacks(GameController controller) {
    controller.onConnect = () {
      if (!mounted) return;
      ConnectionDialogManager.closeConnectionDialogs(context);
    };

    controller.onReconnectionFailed = () {
      if (!mounted) return;

      // 💥 لودر HTML رد میشه تا دیالوگ فلاتر بالا بیاد
      _safeCallOnGameConnected();

      // نمایش دیالوگ شکست اتصال
      ConnectionDialogManager.showReconnectingFailed(context, ref);
    };
  }

  /// 🟢 فراخوانی امن جاوااسکریپت برای رد کردن لودر HTML تلگرام
  static void _safeCallOnGameConnected() {
    try {
      onGameConnected();
      debugPrint("📢 Telegram HTML loader dismissed via onGameConnected()");
    } catch (e) {
      debugPrint("⚠️ HTML Loader finish event error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectionStatus?>(
      gameControllerProvider.select((state) => state?.connectionStatus),
      (previous, next) {
        if (next == null || previous == next) return;

        if (next == ConnectionStatus.reconnecting) {
          ConnectionDialogManager.showReconnecting(context);
        }
        if (next == ConnectionStatus.connected) {
          ConnectionDialogManager.closeConnectionDialogs(context);
        }
      },
    );

    // 🎵 ۲. مدیریت قطع موزیک منو
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

    final currentStage = ref.watch(
      gameControllerProvider.select((state) => state?.gameStage),
    );

    // ۳. تا زمان آماده‌سازی کامل، صفحه شفاف می‌مونه
    if (currentStage == null ||
        currentStage == GameStage.connectionStage ||
        !_isAssetsLoaded) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      );
    }

    // ۴. رد کردن لودر HTML پس از ورود موفق به اولین Stage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeCallOnGameConnected();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF536E7A),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) {
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
