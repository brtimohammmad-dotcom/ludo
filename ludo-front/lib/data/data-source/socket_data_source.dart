import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/config_service.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';

import 'socket_event_handler.dart';

typedef OnGameEventCallback =
    void Function(String eventName, Map<String, dynamic> data);

class SocketDataSource {
  io.Socket? _socket;
  bool _isConnecting = false;

  // --- کالبک‌ها ---
  OnGameEventCallback? onGameEventReceived;

  // --- وضعیت سیستم ---
  ServerState? serverState;
  Completer<void> playerInitialized = Completer<void>();

  bool get isConnected => _socket?.connected ?? false;

  // -------------------------------------------------------
  // CONNECT
  // -------------------------------------------------------
  void connect(GameMode mode, String? gameId) {
    final serverUrl = Config.serverUrl;
    Config.printEnvironmentInfo();

    if (_isConnecting) return;
    _isConnecting = true;

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

    // اتصال اولیه و فرستادن رکوئست استیت
    _socket!.onConnect((_) {
      onGameEventReceived?.call('connected',{});
      _isConnecting = false;
      _socket!.emit("request_game_state", {
        "gameMode": mode.name,
        "gameId": gameId ?? "",
      });
    });

    // ثبت رویدادها از طریق هندلر اختصاصی
    SocketEventHandler(
      dataSource: this,
      socket: _socket!,
    ).registerEvents(mode, gameId);

    // مدیریت وضعیت دیسکانیکت و ریکانکت سوکت
    _setupConnectionLifeCycle();

    _socket!.connect();
  }

  void _setupConnectionLifeCycle() {
    _socket!.onDisconnect(
      (reason) => onGameEventReceived?.call('disconnect', {}),
    );
    _socket!.onReconnectAttempt((a) => debugPrint("🔄 Reconnect attempt #$a"));
    _socket!.onReconnectError((e) => debugPrint("⚠️ Reconnect error: $e"));
    _socket!.onReconnectFailed((_) => onGameEventReceived?.call('reconnection_failed',{}));
  }

  // -------------------------------------------------------
  // GAME ACTIONS (EMITS)
  // -------------------------------------------------------
  void joinGame(int numberOfPlayers) {
    if (isConnected) {
      _socket!.emit("join_game", {"numberOfPlayers": numberOfPlayers});
    }
  }

  void rollDice() {
    if (isConnected) _socket!.emit("roll_dice");
  }

  void getFastPing() {
    if (isConnected) _socket!.emit("get_fast_ping");
  }

  void moveToken(Token t) {
    if (isConnected) _socket!.emit("move_token", t.toJson());
  }

  void exitGame() {
    if (isConnected) _socket!.emit("exit_game");
  }

  void resumeReconnection() {
    if (_socket != null) {
      _socket!.io.reconnecting = false;
      _socket!.io.skipReconnect = false;
      _socket!.io.reconnect();
    }
  }

  void claimDailyReward() {
    if (isConnected) _socket!.emit("claim_daily_reward");
  }
}
