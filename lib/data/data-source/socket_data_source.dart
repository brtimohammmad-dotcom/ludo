import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/client_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketDataSource {
  io.Socket? _socket;
  ClientState? clientState;

  // تعریفی برای کالبک که وضعیت جدید را دریافت می‌کند
  void Function(GameState)? onStateUpdated;
  Completer<void> clientInitialized = Completer<void>();

  void connectToGame() {
    _socket = io.io(
      'http://localhost:3000',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket!.onConnect((_) => debugPrint('Connected to server'));
    _socket!.on(('initial_player'), (data) {
      clientState = ClientState(
        connectionStatus: ConnectionStatus.connected,
        diceIsRolling: false,
        tokenIsMoving: false,
        isRequestInFlight: false,
        livePlayer: Player.fromJson(data),
      );
      if (!clientInitialized.isCompleted) {
        clientInitialized.complete();
      }
    });

    // وقتی دیتای معمولی می‌آید
    _socket!.on('game_state_update', (data) async {
      await clientInitialized.future;
      final serverState = ServerState.fromJson(data);
      final newState = GameState(
        serverState: serverState,
        clientState: clientState!,
      );

      // پاس دادن دیتا به کنترلر از طریق کالبک
      onStateUpdated?.call(newState);
    });

    // وقتی بازی شروع می‌شود
    _socket!.on('game_started', (data) async {
      await clientInitialized.future;
      debugPrint('game started');
      final serverState = ServerState.fromJson(data);

      final finalState = GameState(
        serverState: serverState,
        clientState: clientState!,
      );

      onStateUpdated?.call(finalState);
    });

    _socket!.on(('dice_rolled'), (data) {
      updateGameState(data);
    });

    _socket!.on(('error'), (data) {
      debugPrint(data);
    });
    _socket!.on(('token_moved'), (data) {
      updateGameState(data);
    });
  }

  void rollDice() {
    _socket!.emit(('roll_dice'));
  }

  void moveToken(Token liveToken) {
    _socket!.emit(('move_token'), (liveToken));
  }

  void emitAction(String event, dynamic data) => _socket?.emit(event, data);

  void updateGameState(dynamic data) {
    final newServerState = ServerState.fromJson(data);
    final newGameState = GameState(
      serverState: newServerState,
      clientState: clientState!,
    );
    onStateUpdated?.call(newGameState);
  }
}
