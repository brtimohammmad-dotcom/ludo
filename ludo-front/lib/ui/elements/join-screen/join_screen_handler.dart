import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/utils/alerts/insufficient_coins_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class JoinScreenHandler {
  final BuildContext context;
  final GameController gameController;
  final AudioService audioService;
  final bool Function() isMounted; // اضافه شدن برای جلوگیری از کرش context

  JoinScreenHandler({
    required this.context,
    required this.gameController,
    required this.audioService,
    required this.isMounted,
  }); // سمی‌کالن اصلاح شد

  void setupControllerCallbacks() {
    gameController.onGameReady = () {
      if (!isMounted()) return; // بررسی زنده بودن ویجت
      if (Navigator.canPop(context)) Navigator.pop(context);

      gameController.updateState(
        gameController.currentGameState?.copyWith(
          gameStage: GameStage.boardStage,
        ),
      );
    };

    gameController.onReconnectionFailed = () {
      if (!isMounted()) return;
      if (Navigator.canPop(context)) Navigator.pop(context);

      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (!isMounted()) return;
            if (Navigator.canPop(context)) Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 50));
            gameController.gameRepository.dataSource.resumeReconnection();
          },
          textButton: "Reconnect",
        ),
      );
    };
    gameController.onInsufficientCoin = () {
      final int playerCoin =
          gameController.currentGameState?.livePlayer?.coin ?? 0;
      if (!isMounted()) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      showAnimatedDialog(
        context: context,
        child: InsufficientCoinsAlert(
          requiredCoins: 100,
          currentCoins: playerCoin,
        ),
      );
    };
  }

  void handleGameSearch(int numberOfPlayers, double boardSize) {
    audioService.playSFX('assets/audio/sound-effect/friend_button_sound.wav');
    final int playerCoin =
        gameController.currentGameState?.livePlayer?.coin ?? 0;
    final int coinCost = numberOfPlayers > 0 ? 100 : 0;
    if (playerCoin < coinCost) {
      if (!isMounted()) return;
      showAnimatedDialog(
        context: context,
        child: InsufficientCoinsAlert(
          requiredCoins: coinCost,
          currentCoins: playerCoin,
        ),
      );
      return;
    }
    gameController.onFastPingGets = () {
      if (!isMounted()) return;
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
}
