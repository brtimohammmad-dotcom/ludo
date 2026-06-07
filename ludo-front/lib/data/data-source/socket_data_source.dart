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
typedef GameFinishedCallback = void Function(Player player);
typedef ReconnectionFailedCallback = void Function();
typedef OnDisconnectCallback = void Function();
typedef PlayerExitCallback = void Function();

class SocketDataSource {
  io.Socket? socket;
  ServerState? serverState;
  StateUpdateCallback? onStateUpdate;
  PlayerUpdateCallback? onPlayerUpdate;
  TokenMovedCallback? onTokenMoved;
  DiceRolledCallback? onDiceRolled;
  TimesUpCallback? onTimesUp;
  GameFinishedCallback? onGameFinished;
  ReconnectionFailedCallback? onReconnectionFailedCallback;
  OnDisconnectCallback? onDisconnectCallback;
  PlayerExitCallback? onPlayerExit;

  Completer<void> playerInitialized = Completer<void>();

  Map<String, dynamic> convertToJSData(dynamic data) {
    if (data is List && data.isNotEmpty && data[0] is Map) {
      return Map<String, dynamic>.from(data[0] as Map);
    } else if (data is Map<String, dynamic>) {
      return data;
    } else {
      debugPrint('فرمت داده نامعتبر: ${data.runtimeType}');
      return {};
    }
  }

  void connectToGame() async {
    Config.printEnvironmentInfo();
    final serverUrl = Config.serverUrl;

    if (socket != null) {
      if (socket!.connected) {
        debugPrint('⚠️ Socket is already connected. Skipping initialization.');
        return;
      }

      // 🚨 اصلاح شد: اگر سوکت وجود دارد اما دیسکانکت است،
      // به جای زدن متد socket!.connect() که تلاش‌های ریکانکت قبلی را دوبرابر می‌کند،
      // کل سوکت قبلی را نابود کن و بگذار یک سوکت کاملاً جدید از خط پایینی ساخته شود.
      debugPrint('🔄 Ghost socket detected. Disposing before creating a fresh instance...');
      await dispose();
    }

    debugPrint('🟢 Connecting to: $serverUrl');
    socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(6)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(5000)
          .setTimeout(3500)
          .setQuery({'timeout': '3500'})
          .setExtraHeaders({'Connection': 'upgrade'})
          .build(),
    );

    socket!.onConnect((_) {
      dynamic initData;
      debugPrint('✅ Connected to $serverUrl');
      final isLocal =
          Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1';
      if (isLocal) {
        initData = {"first_name": "amir", "id": 0};
      } else {
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.ready();
          TelegramWebApp.instance.expand();
        }
        initData = TelegramWebApp.instance.initData.raw;
      }

      // 🚨 اصلاح شد: هر زمان که اتصال برقرار می‌شود (چه بار اول، چه ریکانکت بومی سوکت)،
      // باید دیتای auth فرستاده شود تا سرور کلاینت قدیمی و جدید را جابجا کند و دوقلو ایجاد نشود.
      debugPrint('📤 Sending auth event to server...');
      socket!.emit("auth", {"initData": initData});
    });

    socket!.on('initial_player', (data) {
      Player livePlayer = Player.fromJson(convertToJSData(data));
      debugPrint('👤 Initial Player received: ${livePlayer.username}');
      onPlayerUpdate?.call(livePlayer);
      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }
    });

    socket!.on('game_state_update', (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onStateUpdate?.call(serverState!);
    });

    socket!.on('game_started', (data) async {
      await playerInitialized.future;
      debugPrint('game started');
      serverState = ServerState.fromJson(convertToJSData(data));
      onStateUpdate?.call(serverState!);
    });

    socket!.on('dice_rolled', (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onDiceRolled?.call(serverState!);
    });

    socket!.on('times_up', (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onTimesUp?.call(serverState!);
    });

    socket!.on('game_finished', (data) async {
      await playerInitialized.future;
      Player winner = Player.fromJson(convertToJSData(data));
      onGameFinished?.call(winner);
    });

    socket!.on('player_exit', (data) async {
      await playerInitialized.future;
      socket!.clearListeners(); // پاک کردن تمام لیسنرهای رویدادها (.on)

      onPlayerExit?.call();
    });

    socket!.on('error', (data) {
      debugPrint('Socket error: $data');
    });

    socket!.on('token_moved', (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onTokenMoved?.call(serverState!);
    });

    socket!.onDisconnect((_) {
      debugPrint('🔌 Socket disconnected.');
      // 🚨 اصلاح شد: وقتی دیسکانکت می‌شود، وضعیت کامپلیتر را ریست کنید تا برای کانکت بعدی منتظر توکن بماند
      if (playerInitialized.isCompleted) {
        playerInitialized = Completer<void>();
      }
      onDisconnectCallback?.call();
    });

    socket!.onReconnectAttempt((attempt) {
      debugPrint('🔄 Socket reconnect attempt #$attempt');
    });

    socket!.onReconnectError((error) {
      debugPrint('⚠️ Reconnect error: $error');
    });

    socket!.onReconnectFailed((_) async {
      debugPrint('❌ [FATAL] Reconnection failed after all attempts.');
      onReconnectionFailedCallback?.call();
    });
  }

  Future<void> dispose() async {
    debugPrint("🧹 Fully disposing SocketDataSource and clearing memory...");

    // ۱. مدیریت و قطع اتصال سوکت به صورت امن
    if (socket != null) {
      try {
        if (socket!.connected) {
          socket!.disconnect(); // قطع اتصال از سرور
        }
        socket!.clearListeners(); // پاک کردن تمام لیسنرهای رویدادها (.on)
        socket!.close(); // بستن کامل منبع سوکت
      } catch (e) {
        debugPrint("⚠️ Error while closing socket: $e");
      } finally {
        socket = null; // آزاد کردن متغیر سوکت برای گاربج کالکتور
      }
    }

    // ۲. پاکسازی و ریست کردن کالبک‌ها (تغییر ارجاعات به null)
    // این کار باعث می‌شود کنترلر سینگلتون دیگر به توابع قدیمی ارجاع نداشته باشد
    onStateUpdate = null;
    onPlayerUpdate = null;
    onTokenMoved = null;
    onDiceRolled = null;
    onTimesUp = null;
    onGameFinished = null;
    onReconnectionFailedCallback = null;
    onDisconnectCallback = null;
    onPlayerExit = null;

    // ۳. پاکسازی وضعیت بازی (State) ذخیره شده
    serverState = null;

    // ۴. بازنشانی کامل Completer برای اتصالات بعدی
    // اگر کامپلیتر قبلاً تکمیل شده باشد، یک نمونه جدید و خام جایگزین می‌کنیم
    if (playerInitialized.isCompleted) {
      playerInitialized = Completer<void>();
    } else {
      // اگر تکمیل نشده بود هم برای اطمینان مجدد ساختار خام می‌دهیم
      playerInitialized = Completer<void>();
    }

    debugPrint("✅ SocketDataSource is now completely clean.");
  }

  void joinGame(int gameMode) {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot join game: socket not connected');
      return;
    }
    socket!.emit('join_game', {'gameMode': gameMode});
  }

  void rollDice() {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot roll dice: socket not connected');
      return;
    }
    socket!.emit('roll_dice');
  }

  void exitGame() {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot exit game: socket not connected');
      return;
    }
    socket!.emit("exit_game");
  }

  void moveToken(Token liveToken) {
    if (socket == null || !socket!.connected) {
      debugPrint('Cannot move token: socket not connected');
      return;
    }
    socket!.emit('move_token', liveToken.toJson());
  }

  void demoDisconnectAndConnect() {
    final engine = socket?.io.engine;
    if (engine != null) {
      engine.close();
      debugPrint('Engine closed - simulating internet cut');
    }
  }
}
