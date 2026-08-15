import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:ludo/data/data-source/socket_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/config_service.dart';

import 'socket_event_handler.dart';

typedef OnGameEventCallback =
    void Function(String eventName, Map<String, dynamic> data);

class SocketDataSource {
  io.Socket? _socket;
  bool _isConnecting = false;
  final GameType gameType;
  final String? gameId;

  SocketDataSource({required this.gameType, this.gameId});

  // --- کالبک‌ها ---
  OnGameEventCallback? onGameEventReceived;

  // --- وضعیت سیستم ---
  ServerState? serverState;
  Completer<void> playerInitialized = Completer<void>();

  bool get isConnected => _socket?.connected ?? false;

  // -------------------------------------------------------
  // CONNECT
  // -------------------------------------------------------
  void connect() {
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
          .setAckTimeout(3000)
          .build(),
    );
    // اتصال اولیه و فرستادن رکوئست استیت
    _socket!.onConnect((_) {
      onGameEventReceived?.call('connected', {});
      _isConnecting = false;
      requestGameState();
    });
    // ثبت رویدادها از طریق هندلر اختصاصی
    SocketEventHandler(dataSource: this, socket: _socket!).registerEvents();

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
    _socket!.onReconnectFailed(
      (_) => onGameEventReceived?.call('reconnection_failed', {}),
    );
  }

  // -------------------------------------------------------
  // GAME ACTIONS (EMITS WITH ACK)
  // -------------------------------------------------------

  /// ورود به بازی / لابی
  void joinGame({
    required int numberOfPlayers,
    required GameType gameType,
    required GameLevel gameLevel,
    Function(dynamic response)? onAck,
  }) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "join_game",
      {
        "numberOfPlayers": numberOfPlayers,
        "gameType": gameType.name,
        "gameLevel": gameLevel.name,
      },
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  /// ریختن تاس
  void rollDice({Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "roll_dice",
      {},
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  /// حرکت مهره
  void moveToken(Token t, {Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "move_token",
      t.toJson(),
      ack: (dynamic err, [dynamic response]) {
        if (response == null && err == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  /// خروج از بازی
  void exitGame({Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "exit_game",
      {},
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  /// دریافت پاداش روزانه
  void claimDailyReward({Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "claim_daily_reward",
      {},
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  /// خرید vpn
  void redeemVpn(int gb, {Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "redeem_vpn",
      gb,
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  void getLeaderBoardList({Function(dynamic response)? onAck}) {
    if (!isConnected) return;
    _socket!.emitWithAck(
      "get_leader_board_list",
      {},
      ack: (dynamic err, [dynamic response]) {
        if (response == null) {
          // تایم‌اوت شد (سرور جواب نداد)
          onAck?.call({'success': false});
        } else {
          final cleanData = SocketUtils.convertToJSData(response);
          onAck?.call(cleanData);
        }
      },
    );
  }

  // -------------------------------------------------------
  // FIRE AND FORGET EMITS (WITHOUT ACK)
  // -------------------------------------------------------
  void requestGameState() {
    _socket!.emit("request_game_state", {
      "gameType": gameType.name.toString(),
      "gameId": gameId ?? "",
    });
  }

  void sendEmoji(String emojiName) {
    if (isConnected) _socket!.emit("send_emoji", emojiName);
  }

  void getFastPing() {
    if (isConnected) _socket!.emit("get_fast_ping");
  }

  void resumeReconnection() {
    if (_socket != null) {
      _socket!.io.reconnecting = false;
      _socket!.io.skipReconnect = false;
      _socket!.io.reconnect();
    }
  }
}
