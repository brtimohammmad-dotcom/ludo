import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

import 'widgets/start_game_button.dart';
import 'widgets/animated_friends_buttons.dart';

enum GameMode { global, friendly }

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  bool _showFriendsOptions = false;

  // late final Future<LottieComposition> _happyDiceComposition;

  @override
  void initState() {
    super.initState();

    // 🟢 ۱. پیش‌بارگذاری انیمیشن لاتی در بدو ورود به کامپوننت برای رندر آنی
    // _happyDiceComposition = AssetLottie(
    //   "assets/lotties/Happy Dice.json",
    // ).load();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupControllerCallbacks();
    });
  }

  void _setupControllerCallbacks() {
    final gameController = ref.read(gameControllerProvider.notifier);
    gameController.onGameReady = () {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      gameController.updateState(
        gameController.currentGameState?.copyWith(
          gameStage: GameStage.boardStage,
        ),
      );
    };

    gameController.gameRepository.dataSource.onDisconnectCallback = () {
      if (mounted && TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert('Connection lost. Reconnecting...');
      }
    };

    gameController.onReconnectionFailed = () {
      if (Navigator.canPop(context)) Navigator.pop(context);

      if (!mounted) return;

      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (Navigator.canPop(context)) Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 50));
            gameController.gameRepository.dataSource.resumeReconnection();
          },
          textButton: "Reconnect",
        ),
      );
    };
  }

  void _handleGameSearch(int numberOfPlayers, double boardSize) {
    final gameController = ref.read(gameControllerProvider.notifier);

    gameController.onFastPingGets = () {
      gameController.startGame(numberOfPlayers: numberOfPlayers);
      _showWaitingDialog(boardSize);
    };
    gameController.getFastPing();
  }

  void _showWaitingDialog(double boardSize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.fourRotatingDots(
              color: Colors.lightGreenAccent,
              size: boardSize * 0.2,
            ),
            SizedBox(height: boardSize * 0.01),
            const Text(
              'Waiting for Game',
              style: TextStyle(
                fontSize: 20,
                color: Colors.lightGreenAccent,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // FutureBuilder<LottieComposition>(
              //   future: _happyDiceComposition,
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       return Lottie(
              //         composition: snapshot.data,
              //         width: 200,
              //         height: 200,
              //         fit: BoxFit.cover,
              //       );
              //     }
              //     // یک باکس خالی بسیار سبک تا زمان رندر میلی‌ثانیه‌ای لاتی
              //     return const SizedBox(width: 200, height: 200);
              //   },
              // ),
              // به جای FutureBuilder سنگین لاتی، فقط همین را جایش بگذار:
              Image.asset(
                "assets/webp/happy-dice.webp",
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StartGameButton(
                    numberOfPlayers: 2,
                    onPressed: () => _handleGameSearch(2, boardSize),
                  ),
                  const SizedBox(width: 10),
                  StartGameButton(
                    numberOfPlayers: 4,
                    onPressed: () => _handleGameSearch(4, boardSize),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              StartGameButton(
                numberOfPlayers: -1,
                onPressed: () {
                  setState(
                    () => _showFriendsOptions = !_showFriendsOptions,
                  );
                },
              ),
              SizedBox(height: 15,),
              AnimatedFriendsButtons(
                boardSize: boardSize,
                show: _showFriendsOptions,
                onPlay2Players: () => _handleGameSearch(-2, boardSize),
                onPlay4Players: () => _handleGameSearch(-4, boardSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
