import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

typedef StateUpdateCallback = void Function(ServerState state);
typedef PlayerUpdateCallback = void Function(Player player);
typedef TokenMovedCallback = void Function(ServerState state);

class SocketDataSource {
  io.Socket? _socket;
  Player? livePlayer;
  ServerState? serverState;

  StateUpdateCallback? onStateUpdate;
  PlayerUpdateCallback? onPlayerUpdate;
  TokenMovedCallback? onTokenMoved;

  SocketDataSource();

  Completer<void> playerInitialized = Completer<void>();

  void connectToGame() {
    _socket = io.io(
      'http://localhost:3000',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket!.onConnect((_) => debugPrint('Connected to server'));
    _socket!.on(('initial_player'), (data) {
      livePlayer = Player.fromJson(data);
      onPlayerUpdate?.call(livePlayer!);
      if (!playerInitialized.isCompleted) {
        playerInitialized.complete();
      }
    });

    _socket!.on('game_state_update', (data) async {
      await playerInitialized.future;
      serverState = ServerState.fromJson(data);
      onStateUpdate?.call(serverState!);
    });

    // وقتی بازی شروع می‌شود
    _socket!.on('game_started', (data) async {
      await playerInitialized.future;
      debugPrint('game started');
      serverState = ServerState.fromJson(data);
      onStateUpdate?.call(serverState!);
    });

    _socket!.on(('dice_rolled'), (data) {
      serverState = ServerState.fromJson(data);
      onStateUpdate?.call(serverState!);
    });

    _socket!.on(('error'), (data) {
      debugPrint('Socket error: $data');
    });
    _socket!.on(('token_moved'), (data) async {
      await playerInitialized.future;
      final Map<String, dynamic> json = data as Map<String, dynamic>;
      serverState = ServerState.fromJson(json);
      onTokenMoved?.call(serverState!);
    });
  }

  void rollDice() {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Cannot roll dice: socket not connected');
      return;
    }
    _socket!.emit('roll_dice');
  }

  void moveToken(Token liveToken) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Cannot move token: socket not connected');
      return;
    }
    _socket!.emit('move_token', liveToken.toJson());
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
