import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/config_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:telegram_web_app/telegram_web_app.dart';

typedef StateUpdateCallback = void Function(ServerState state);
typedef PlayerUpdateCallback = void Function(Player player);
typedef TokenMovedCallback = void Function(ServerState state);
typedef DiceRolledCallback = void Function(ServerState state);
typedef TimesUpCallback = void Function(ServerState state);
typedef GameFinishedCallback = void Function(ServerState state);
typedef ReconnectionFailedCallback = void Function();

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
  ReconnectionFailedCallback? onReconnectionFailedCallback;

  Completer<void> playerInitialized = Completer<void>();

  Map<String, dynamic> convertToJSData(dynamic data) {
    if (data is List && data.isNotEmpty && data[0] is Map) {
      // آیتم اول لیست را که Map است بردار
      return Map<String, dynamic>.from(data[0] as Map);
    } else if (data is Map<String, dynamic>) {
      // اگر مستقیم Map بود (حالت عادی)
      return data;
    } else {
      debugPrint('فرمت داده نامعتبر: ${data.runtimeType}');
      return {};
    }
  }

  void connectToGame({required int gameMode}) async {
    Config.printEnvironmentInfo();

    final serverUrl = Config.serverUrl;
    print('🟢 Connecting to: $serverUrl');
    socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling']) // فقط همین کافی است
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(12) // تعداد تلاش برای reconnect
          .setReconnectionDelay(5000) // تأخیر بین تلاش‌ها (ms)
          .setReconnectionDelayMax(60 * 1000) // حداکثر تأخیر
          .setTimeout(20000) // timeout اتصال (ms)
          .build(),
    );
    socket!.onConnect((_) {
      dynamic initData;
      print('✅ Connected to $serverUrl');
      final isLocal =
          Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1';
      if (isLocal) {
        initData = {"first_name": "amir", "id": 0};
      } else {
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.ready();
          TelegramWebApp.instance.expand(); // مینی‌آپ را تمام‌صفحه می‌کند
        }
        initData = TelegramWebApp.instance.initData.raw;
      }

      if (playerInitialized.isCompleted && livePlayer != null) {
        print(
          '🔄 Reconnect detected - re-authenticating player ${livePlayer!.userId}',
        );
      } else {
        // اتصال اولیه
        socket!.emit("auth", {"initData": initData, "gameMode": gameMode});
      }
    });
    // ✅ در حال تلاش برای reconnect

    socket!.on(('initial_player'), (data) {
      livePlayer = Player.fromJson(convertToJSData(data));
      debugPrint(livePlayer!.userId.toString());
      debugPrint(livePlayer!.username.toString());
      onPlayerUpdate?.call(livePlayer!);
      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }
    });

    socket!.on('game_state_update', (data) async {
      await playerInitialized.future;

      serverState = ServerState.fromJson(convertToJSData(data));
      onStateUpdate?.call(serverState!);
    });

    // وقتی بازی شروع می‌شود
    socket!.on('game_started', (data) async {
      await playerInitialized.future;

      debugPrint('game started');
      serverState = ServerState.fromJson(convertToJSData(data));
      livePlayer = serverState!.players.firstWhere((p) {
        return p.userId == livePlayer!.userId;
      });
      onStateUpdate?.call(serverState!);
    });

    socket!.on(('dice_rolled'), (data) async {
      await playerInitialized.future;

      serverState = ServerState.fromJson(convertToJSData(data));
      onDiceRolled?.call(serverState!);
    });

    socket!.on(('times_up'), (data) async {
      await playerInitialized.future;

      serverState = ServerState.fromJson(convertToJSData(data));
      onTimesUp?.call(serverState!);
    });
    socket!.on(('game_finished'), (data) async {
      await playerInitialized.future;

      serverState = ServerState.fromJson(convertToJSData(data));
      socket!.disconnect();
      socket!.close();
      onGameFinished?.call(serverState!);
    });

    socket!.on(('error'), (data) {
      debugPrint('Socket error: $data');
    });
    socket!.on(('token_moved'), (data) async {
      await playerInitialized.future;

      serverState = ServerState.fromJson(convertToJSData(data));
      onTokenMoved?.call(serverState!);
    });
    socket!.onReconnectFailed((data) {
      debugPrint("reconnecting failed");
      onReconnectionFailedCallback?.call();
    });
    socket!.onReconnectAttempt((data) {
      debugPrint("reconnect attempt");
    });

    socket!.onReconnectError((data) {
      debugPrint("reconnect error $data");
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

  void demoDisconnectAndConnect() {
    final engine = socket?.io.engine;
    if (engine != null) {
      engine.close(); // بستن low-level connection بدون پاک کردن session
      print('Engine closed - simulating internet cut');
      // Socket.IO به صورت خودکار reconnect می‌کند
    }
  }
}
