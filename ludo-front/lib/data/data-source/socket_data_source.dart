import 'dart:async';
import 'dart:convert';

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
    if (data == null) {
      debugPrint('⚠️ داده ورودی null است.');
      return {};
    }

    // لایه ۱: اگر داده خودش مستقیم یک مپ استاندارد دارت باشد
    if (data is Map<String, dynamic>) {
      return data;
    }

    try {
      // لایه ۲: بررسی اینکه آیا داده یک لیست یا امتداد قابل پیمایش است (مانند JSArray)
      if (data is Iterable && data.isNotEmpty) {
        final firstElement = data.first;
        if (firstElement is Map) {
          return Map<String, dynamic>.from(firstElement);
        }
        // اگر عنصر اول لیست، خودش یک ساختار دیگر بود، آن را دوباره بررسی کن
        return convertToJSData(firstElement);
      }

      // لایه ۳: اگر داده یک مپ با انواع دیگر کلیدها است (مثلاً Map<dynamic, dynamic>)
      if (data is Map) {
        return data.map((key, value) => MapEntry(key.toString(), value));
      }

      // لایه ۴: بررسی اینکه آیا داده به صورت یک رشته JSON خام (String) فرستاده شده است
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        } else if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.first is Map) {
          return Map<String, dynamic>.from(decoded.first);
        }
      }

      // لایه ۵: برخورد امن با اشیاء خاص جاوااسکریپت (مخصوص وب)
      // برای مواقعی که پکیج سوکت شیء بومی مروگر را بدون تبدیل کلاینتی تحویل می‌دهد
      if (data.toString() == '[object Object]' ||
          data.toString().startsWith('{')) {
        try {
          // تلاش برای استخراج کلیدها به روش تبدیل دستی به مپ دارت
          final converted = Map<dynamic, dynamic>.from(data as dynamic);
          return converted.map((key, value) => MapEntry(key.toString(), value));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('🚨 خطا در حین کالبدشکافی داده سوکت: $e');
    }

    // لایه آخر: اگر به هر دلیلی کدهای بالا نتوانستند ساختار را تشخیص دهند، برای اینکه خروجی کرش نکند،
    // تلاش می‌کنیم نوع داده دریافتی را دقیقاً پرینت کنیم تا بفهمیم سرور چه چیزی فرستاده است.
    debugPrint(
      '❌ ساختار ناشناخته سوکت کلاینت. نوع داده: ${data.runtimeType} | مقدار: $data',
    );
    return {};
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
      debugPrint(
        '🔄 Ghost socket detected. Disposing before creating a fresh instance...',
      );
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
      Future.delayed(const Duration(milliseconds: 300), () {
        debugPrint('📤 Sending auth event to server...');
      });
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
      if (data == null) {
        dynamic initData;

        debugPrint(
          '⚠️ سرور دیتای خالی فرستاد. درخواست مجدد احراز هویت بعد از ۱ ثانیه...',
        );
        Future.delayed(const Duration(seconds: 1), () {
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
        return; // بقیه کد را اجرا نکن و منتظر پاسخ بعدی بمان
      }
      debugPrint(
        '📥 RAW DATA RECEIVED: Type: ${data.runtimeType} | Value: $data',
      );
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
