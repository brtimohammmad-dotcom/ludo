import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/utils/alerts/insufficient_coins_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/welcome_gift_dialog.dart';
import 'package:ludo/ui/utils/alerts/welcome_gift_success_dialog.dart';

class JoinScreenHandler {
  final BuildContext context;
  final GameController gameController;
  final AudioService audioService;
  final bool Function() isMounted;

  JoinScreenHandler({
    required this.context,
    required this.gameController,
    required this.audioService,
    required this.isMounted,
  });

  void setupControllerCallbacks() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);
    if (Navigator.canPop(context)) Navigator.pop(context);
    gameController.onGameReady = () {
      if (!isMounted()) return;
      if (Navigator.canPop(context)) Navigator.pop(context);

      gameController.updateState(
        gameController.currentGameState?.copyWith(
          gameStage: GameStage.boardStage,
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
          requiredCoins:
              gameController.currentGameState!.serverState!.level.entryFee,
          currentCoins: playerCoin,
        ),
      );
    };
    gameController.onWelcomeGiftClaimed = (VpnConfig config) {
      debugPrint("onWelcomeGiftClaimed called");
      if (Navigator.canPop(context)) Navigator.pop(context);
      showAnimatedDialog(
        context: context,
        child: WelcomeGiftSuccessDialog(
          boardSize: boardSize,
          configUrl: config.subscriptionUrl,
        ),
      );
    };

    if (gameController.currentGameState?.livePlayer?.welcomeGift == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isMounted()) return;

        final livePlayer = gameController.currentGameState?.livePlayer;
        if (livePlayer == null) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WelcomeGiftDialog(boardSize: boardSize),
        );
      });
    }
  }

  void handleGameSearch({
    required int numberOfPlayers,
    required GameType gameType,
    required GameLevel gameLevel,
    required double boardSize,
  }) {
    audioService.playSFX('assets/audio/sound-effect/friend_button_sound.wav');

    final int playerCoin =
        gameController.currentGameState?.livePlayer?.coin ?? 0;

    final int coinCost = gameType == GameType.friendly ? 0 : gameLevel.entryFee;

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

      gameController.startGame(
        numberOfPlayers: numberOfPlayers,
        gameType: gameType,
        gameLevel: gameLevel,
      );
      gameController.startLoading("waiting_for_game");
    };
    gameController.getFastPing();
  }
}
