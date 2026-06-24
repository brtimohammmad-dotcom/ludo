import 'package:flutter/foundation.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'dart:js_interop';

@JS('onGameConnected')
external void onGameConnected();

class GameSocketHandler {
  final GameController controller;

  GameSocketHandler(this.controller);

  void init() {
    final ds = controller.gameRepository.dataSource;

    ds.onFastPingGets = () => controller.onFastPingGets?.call();

    ds.onStateUpdate = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      _updateStateAndNotify(state, GameStage.boardStage);
      controller.onGameReady?.call();
      onGameConnected();
      controller.playMenuMusic();
    };

    ds.onInAnotherGameCallback = () {
      if (TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert(
          "You are already in another game!",
          () {},
        );
      }
    };

    ds.onGameRecovered = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      final newLivePlayer = state.players.firstWhere(
        (p) => p.userId == controller.currentGameState!.livePlayer!.userId,
        orElse: () => controller.currentGameState!.livePlayer!,
      );
      controller.updateState(
        GameState(
          serverState: state,
          livePlayer: newLivePlayer,
          gameStage: GameStage.boardStage,
        ),
      );
      onGameConnected();
      controller.playMenuMusic();
    };

    ds.onGameStarted = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      _updateStateAndNotify(state, GameStage.boardStage);
      controller.animationController?.forward();
      controller.onGameStarted?.call();
    };

    ds.onPlayerJoined = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      _updateStateAndNotify(state, GameStage.boardStage);
    };

    ds.onTimesUp = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      final isMyTurn =
          state.currentTurn == controller.currentGameState!.livePlayer!.color &&
          state.gameStatus == GameStatus.start;
      if (isMyTurn) {
        controller.playSfx("assets/audio/sound-effect/current_turn_sound.wav");
      }
      _updateStateAndNotify(state, GameStage.boardStage);
    };

    ds.onGameFinished = (Player winner) {
      if (controller.currentGameState == null) return;
      controller.animationController?.stop();

      controller.updateState(
        controller.currentGameState!.copyWith(
          serverState: controller.currentGameState!.serverState!.copyWith(
            winner: winner,
          ),
        ),
      );

      if (!controller.isGameFinishedHandled &&
          controller.onGameFinished != null) {
        controller.isGameFinishedHandled = true;
        controller.onGameFinished!();
      }
    };

    ds.onReconnectionFailedCallback = () {
      controller.animationController?.stop();
      controller.onReconnectionFailed?.call();
    };

    ds.onPlayerUpdate = (Player player) {
      controller.updateState(
        GameState(
          serverState: controller.currentGameState?.serverState,
          livePlayer: player,
        ),
      );
    };
    ds.onNotInGame = () {
      controller.updateState(
        GameState(
          serverState: controller.currentGameState?.serverState,
          livePlayer: controller.currentGameState?.livePlayer,
          gameStage: GameStage.joinStage,
        ),
      );
      onGameConnected();
      controller.playMenuMusic();
    };
    ds.onPlayerExit = () {
      controller.onPlayerExit?.call();
    };

    ds.onOpponentExit = (ServerState state) {
      if (controller.currentGameState?.livePlayer == null) return;
      _updateStateAndNotify(state, GameStage.boardStage);
      debugPrint('opponent Exit');
    };

    ds.onTokenMoved = (ServerState newState) async {
      // تشخیص اینکه آیا این حرکت توسط خود این کاربر انجام شده بود یا دیگران
      final isMyMovement =
          controller.currentGameState!.serverState!.currentTurn ==
          controller.currentGameState?.livePlayer?.color;

      if (isMyMovement) {
        // اگر انیمیشن محلی هنوز تمام نشده، صبر کن تا باز شدن پرچم
        while (controller.isMovingToken) {
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // حالا که انیمیشن خودمان تمام شده، استیت نهایی سرور را بدون انیمیشن مجدد اعمال کن
        _updateStateAndNotify(newState, GameStage.boardStage);
      } else {
        // اگر حرکت بازیکنان دیگر بود، روال قبلی را برو (انیمیشن مرحله به مرحله)
        await controller.handleTokenMoved(newState);
      }
      final isMyTurn =
          newState.currentTurn == controller.currentGameState!.livePlayer!.color &&
              newState.gameStatus == GameStatus.start;
      if (isMyTurn) {
        controller.playSfx("assets/audio/sound-effect/current_turn_sound.wav");
      }
      _updateStateAndNotify(newState, GameStage.boardStage);
    };

    ds.onDiceRolled = (ServerState newState) async {
      await controller.handleDiceRolled(newState);
      final isMyTurn =
          newState.currentTurn == controller.currentGameState!.livePlayer!.color &&
              newState.gameStatus == GameStatus.start;
      if (isMyTurn) {
        controller.playSfx("assets/audio/sound-effect/current_turn_sound.wav");
      }
    };
  }

  void _updateStateAndNotify(ServerState state, GameStage gameStage) {
    final newLivePlayer = state.players.firstWhere(
      (p) => p.userId == controller.currentGameState!.livePlayer!.userId,
      orElse: () => controller.currentGameState!.livePlayer!,
    );
    controller.updateState(
      GameState(
        serverState: state,
        livePlayer: newLivePlayer,
        gameStage: gameStage,
      ),
    );
  }
}
