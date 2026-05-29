import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:telegram_web_app/telegram_web_app.dart';

typedef StateUpdateCallback = void Function(ServerState state);
typedef PlayerUpdateCallback = void Function(Player player);
typedef TokenMovedCallback = void Function(ServerState state);
typedef DiceRolledCallback = void Function(ServerState state);
typedef TimesUpCallback = void Function(ServerState state);
typedef GameFinishedCallback = void Function(ServerState state);

class SocketDataSource {
  io.Socket? socket;
  Player? livePlayer;
  ServerState? serverState;

  StateUpdateCallback? onStateUpdate;
  PlayerUpdateCallback? onPlayerUpdate;
  TokenMovedCallback? onTokenMoved;
  DiceRolledCallback? onDiceRolled;
  TimesUpCallback? onTimesUp;
  GameFinishedCallback? onGameFinished;

  Completer<void> playerInitialized = Completer<void>();

  void connectToGame({required int gameMode}) async {
    socket = io.io(
      'https://ludo-backend-8ihb.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket', 'polling']) // ابتدا وب‌ساکت، اگر نشد پولینگ
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    socket!.onConnect((_) {
      if (TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.ready();
        TelegramWebApp.instance.expand(); // مینی‌آپ را تمام‌صفحه می‌کند
      }
      final String initData = TelegramWebApp.instance.initData.raw;
      socket!.emit("auth", {
        "initData": initData,
        "gameMode": gameMode,
      });
    });
    socket!.on(('initial_player'), (data) {
      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      livePlayer = Player.fromJson(jsData);
      debugPrint(livePlayer!.userId.toString());
      debugPrint(livePlayer!.username.toString());
      onPlayerUpdate?.call(livePlayer!);
      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }
    });

    socket!.on('game_state_update', (data) async {
      await playerInitialized.future;

      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      serverState = ServerState.fromJson(jsData);
      onStateUpdate?.call(serverState!);
    });

    // وقتی بازی شروع می‌شود
    socket!.on('game_started', (data) async {
      await playerInitialized.future;

      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      debugPrint('game started');
      serverState = ServerState.fromJson(jsData);
      livePlayer = serverState!.players.firstWhere((p) {
        return p.userId == livePlayer!.userId;
      });

      onStateUpdate?.call(serverState!);
    });

    socket!.on(('dice_rolled'), (data) async {
      await playerInitialized.future;

      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      serverState = ServerState.fromJson(jsData);
      onDiceRolled?.call(serverState!);
    });

    socket!.on(('times_up'), (data) async {
      await playerInitialized.future;

      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      serverState = ServerState.fromJson(jsData);
      onTimesUp?.call(serverState!);
    });
    socket!.on(('game_finished'), (data) async {
      await playerInitialized.future;
      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      serverState = ServerState.fromJson(jsData);
      socket!.disconnect();
      socket!.close();
      onGameFinished?.call(serverState!);
    });

    socket!.on(('error'), (data) {
      debugPrint('Socket error: $data');
    });
    socket!.on(('token_moved'), (data) async {
      await playerInitialized.future;
      final Map<String, dynamic> jsData = data as Map<String, dynamic>;

      serverState = ServerState.fromJson(jsData);
      onTokenMoved?.call(serverState!);
    });
  }

  void rollDice() {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot roll dice: socket not connected');
      return;
    }
    socket!.emit('roll_dice');
  }

  void exitGame(int telegramId) {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot exit game: socket not connected');
      return;
    }
    socket!.emit("exit_game", telegramId);
  }

  void moveToken(Token liveToken) {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot move token: socket not connected');
      return;
    }
    socket!.emit('move_token', liveToken.toJson());
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
    socket = null;
  }
}
