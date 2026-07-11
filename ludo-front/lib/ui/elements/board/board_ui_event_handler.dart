import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/utils/alerts/game_status_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class BoardUiEventHandler {
  final BuildContext context;
  final GameController gameController;

  BoardUiEventHandler({required this.gameController, required this.context});



  // --- مدیریت نمایش دایالوگ انتظار برای شروع بازی ---
  void checkAndShowWaitingDialog() {
    if (!context.mounted) return;

    // ۱. بررسی وضعیت فعلی استیت بازی قبل از باز کردن دایالوگ
    final currentState = gameController.currentGameState;
    final gameStatus = currentState?.serverState?.gameStatus;

    // فقط در صورتی دایالوگ را باز کن که واقعاً وضعیت منتظر بازیکن باشد
    if (gameStatus == GameStatus.waitingForPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        showAnimatedDialog(
          context: context,
          barrierDismissible: false,
          child: WaitingForPlayersAlert(onExit: () => gameController.exitGame()),
        );
      });
    }
  }
}
