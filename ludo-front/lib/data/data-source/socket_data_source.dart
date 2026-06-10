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
typedef OnGameStartedCallback = void Function(ServerState state);
typedef OnPlayerJoinedCallBack = void Function(ServerState state);
typedef OnGameRecoveredCallback = void Function(ServerState state);

typedef PlayerUpdateCallback = void Function(Player player);
typedef TokenMovedCallback = void Function(ServerState state);
typedef DiceRolledCallback = void Function(ServerState state);
typedef TimesUpCallback = void Function(ServerState state);
typedef GameFinishedCallback = void Function(Player player);
typedef ReconnectionFailedCallback = void Function();
typedef OnDisconnectCallback = void Function();
typedef PlayerExitCallback = void Function();
typedef OnFastPingGetsCallback = void Function();

class SocketDataSource {
  io.Socket? _socket;

  // --- Flags ---
  bool _isConnecting = false;

  // --- Callbacks ---
  StateUpdateCallback? onStateUpdate;
  OnGameStartedCallback? onGameStarted;
  OnPlayerJoinedCallBack? onPlayerJoined;
  PlayerUpdateCallback? onPlayerUpdate;
  OnGameRecoveredCallback? onGameRecovered;
  TokenMovedCallback? onTokenMoved;
  DiceRolledCallback? onDiceRolled;
  TimesUpCallback? onTimesUp;
  GameFinishedCallback? onGameFinished;
  ReconnectionFailedCallback? onReconnectionFailedCallback;
  OnDisconnectCallback? onDisconnectCallback;
  PlayerExitCallback? onPlayerExit;
  OnFastPingGetsCallback? onFastPingGets;

  // --- State ---
  ServerState? serverState;
  Completer<void> playerInitialized = Completer<void>();

  // -------------------------------------------------------
  // SAFE JSON CONVERTER
  // -------------------------------------------------------
  Map<String, dynamic> convertToJSData(dynamic data) {
    if (data == null) return {};

    if (data is Map<String, dynamic>) return data;

    try {
      if (data is Iterable) {
        final list = data.toList();
        if (list.isNotEmpty) {
          final first = list.first;
          try {
            return Map<String, dynamic>.from(first as Map);
          } catch (_) {
            final decoded = jsonDecode(jsonEncode(first));
            if (decoded is Map) {
              return Map<String, dynamic>.from(decoded);
            }
          }
        }
      }

      if (data is Map) {
        return data.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (e) {
      debugPrint('🚨 JSON conversion error: $e');
    }

    return {};
  }

  // -------------------------------------------------------
  // CONNECT
  // -------------------------------------------------------
  void connectToGame() async {
    final serverUrl = Config.serverUrl;
    Config.printEnvironmentInfo();

    if (_isConnecting) {
      debugPrint("⛔ Prevented duplicate connect()");
      return;
    }

    if (_socket != null) {
      debugPrint("🔄 Disposing ghost socket before reconnect...");
      await dispose();
    }

    _isConnecting = true;

    debugPrint("🟢 Connecting to: $serverUrl");

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(6)
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(5000)
          .setTimeout(3500)
          .build(),
    );

    // -------------------------------------------------------
    // ON CONNECT
    // -------------------------------------------------------
    _socket!.onConnect((_) {
      debugPrint("✅ Connected to $serverUrl");
      _isConnecting = false;

      debugPrint("📤 Sending request game state event to server...");
      _socket!.emit("request_game_state");
    });
    // -------------------------------------------------------
    // AUTHORIZE PLAYER
    // -------------------------------------------------------
    _socket!.on("player_not_authorized", (data) {
      dynamic initData;

      if (Uri.base.host == "localhost") {
        initData = {"first_name": "amir", "id": 4};
      } else {
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.ready();
          TelegramWebApp.instance.expand();
        }
        initData = TelegramWebApp.instance.initData.raw;
      }
      _socket!.emit("auth", {"initData": initData});
    });
    // -------------------------------------------------------
    // INITIAL PLAYER
    // -------------------------------------------------------
    _socket!.on("initial_player", (data) {
      debugPrint("📥 RAW DATA RECEIVED: $data");

      final clean = convertToJSData(data);

      if (clean.containsKey("error")) {
        final msg = clean["error"];
        debugPrint("❌ Server error: $msg");

        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.showAlert("خطا در احراز هویت بازی: $msg");
        }
        return;
      }

      final player = Player.fromJson(clean);
      onPlayerUpdate?.call(player);

      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }
      _socket!.emit("request_game_state");
    });
    // -------------------------------------------------------
    // ON GET PING
    // -------------------------------------------------------
    _socket!.on("fast_ping_gets", (data) {
      onFastPingGets?.call();
    });
    // -------------------------------------------------------
    // GAME EVENTS
    // -------------------------------------------------------
    _socket!.on("game_state_update", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onStateUpdate?.call(serverState!);
    });

    _socket!.on("game_started", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onGameStarted?.call(serverState!);
    });
    _socket!.on("player_joined", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onPlayerJoined?.call(serverState!);
    });
    _socket!.on("game_recovered", (data) async {

      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }

      serverState = ServerState.fromJson(convertToJSData(data));
      onGameRecovered?.call(serverState!);
    });
    _socket!.on("dice_rolled", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onDiceRolled?.call(serverState!);
    });

    _socket!.on("times_up", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onTimesUp?.call(serverState!);
    });

    _socket!.on("game_finished", (data) async {
      await playerInitialized.future;
      final winner = Player.fromJson(convertToJSData(data));
      onGameFinished?.call(winner);
    });

    _socket!.on("token_moved", (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(convertToJSData(data));
      onTokenMoved?.call(serverState!);
    });

    _socket!.on("player_exit", (_) async {
      await playerInitialized.future;
      _socket!.clearListeners();
      onPlayerExit?.call();
    });

    // -------------------------------------------------------
    // DISCONNECT / RECONNECT
    // -------------------------------------------------------
    _socket!.onDisconnect((reason) {
      debugPrint("🔌 Socket disconnected: $reason");

      onDisconnectCallback?.call();
    });

    _socket!.onReconnectAttempt((a) {
      debugPrint("🔄 Reconnect attempt #$a");
    });

    _socket!.onReconnectError((e) {
      debugPrint("⚠️ Reconnect error: $e");
    });

    _socket!.onReconnectFailed((_) {
      debugPrint("❌ Reconnect failed");
      if (playerInitialized.isCompleted) {
        playerInitialized = Completer<void>();
      }
      onReconnectionFailedCallback?.call();
    });

    _socket!.connect();
  }

  // -------------------------------------------------------
  // DISPOSE
  // -------------------------------------------------------
  Future<void> dispose() async {
    debugPrint("🧹 Disposing SocketDataSource...");

    // ⛔ اول هر جور reconnect رو قطع کن
    try {
      if (_socket != null) {
        _socket!.io.options?['reconnection'] = false;
        _socket!.io.options?['reconnectionAttempts'] = 0;
      }
    } catch (_) {}

    try {
      _socket?.clearListeners();
      _socket?.disconnect();
      _socket?.destroy();
    } catch (_) {}

    _socket = null;

    onStateUpdate = null;
    onPlayerUpdate = null;
    onTokenMoved = null;
    onDiceRolled = null;
    onTimesUp = null;
    onGameFinished = null;
    onReconnectionFailedCallback = null;
    onDisconnectCallback = null;
    onPlayerExit = null;
    onFastPingGets = null;

    serverState = null;

    if (playerInitialized.isCompleted) {
      playerInitialized = Completer<void>();
    }

    debugPrint("✅ SocketDataSource fully cleaned.");
  }

  // -------------------------------------------------------
  // GAME ACTIONS
  // -------------------------------------------------------
  bool get isConnected => _socket?.connected ?? false;

  void joinGame(int mode) {
    if (_socket?.connected ?? false) {
      _socket!.emit("join_game", {"gameMode": mode});
    }
  }

  void rollDice() {
    if (_socket?.connected ?? false) {
      _socket!.emit("roll_dice");
    }
  }

  void getFastPing() {
    if (onFastPingGets != null) onFastPingGets!();
  }

  void moveToken(Token t) {
    if (_socket?.connected ?? false) {
      _socket!.emit("move_token", t.toJson());
    }
  }

  void exitGame() {
    if (_socket?.connected ?? false) {
      _socket!.emit("exit_game");
    }
  }
}
