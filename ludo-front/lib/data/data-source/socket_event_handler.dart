import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';
import 'socket_data_source.dart';
import 'socket_utils.dart';

class SocketEventHandler {
  final SocketDataSource dataSource;
  final io.Socket socket;

  SocketEventHandler({required this.dataSource, required this.socket});

  void registerEvents(GameMode mode, String? gameId) {
    // --- احراز هویت تلگرام ---
    socket.on("player_not_authorized", (_) {
      dynamic initData;
      if (Uri.base.host == "localhost") {
        initData = {"first_name": "amir", "id":3};
      } else {
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.ready();
          TelegramWebApp.instance.expand();
        }
        initData = TelegramWebApp.instance.initData.raw;
      }
      socket.emit("auth", {"initData": initData});
    });

    // --- وضعیت‌های عمومی بازی ---
    socket.on("not_in_game", (_) => dataSource.onNotInGame?.call());

    socket.on("in_another_game", (_) {
      dataSource.onInAnotherGameCallback?.call();
      _requestGameState(mode, gameId);
    });

    socket.on("fast_ping_gets", (_) => dataSource.onFastPingGets?.call());

    // --- بازیکن اولیه ---
    socket.on("initial_player", (data) {
      final clean = SocketUtils.convertToJSData(data);

      if (clean.containsKey("error")) {
        final msg = clean["error"];
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.showAlert("خطا در احراز هویت بازی: $msg");
        }
        return;
      }

      final player = Player.fromJson(clean);
      dataSource.onPlayerUpdate?.call(player);

      if (!dataSource.playerInitialized.isCompleted) {
        dataSource.playerInitialized.complete();
      }
      _requestGameState(mode, gameId);
    });

    // --- رویدادهای اصلی گیم‌پلی ---
    socket.on("game_state_update", (data) async {
      await dataSource.playerInitialized.future;
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onStateUpdate?.call(dataSource.serverState!);
    });

    socket.on("game_started", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onGameStarted?.call(dataSource.serverState!);
    });

    socket.on("player_joined", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onPlayerJoined?.call(dataSource.serverState!);
    });

    socket.on("game_recovered", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onGameRecovered?.call(dataSource.serverState!);
    });

    socket.on("dice_rolled", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onDiceRolled?.call(dataSource.serverState!);
    });

    socket.on("times_up", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onTimesUp?.call(dataSource.serverState!);
    });

    socket.on("token_moved", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onTokenMoved?.call(dataSource.serverState!);
    });

    socket.on("opponent_exit", (data) {
      dataSource.serverState = ServerState.fromJson(
        SocketUtils.convertToJSData(data),
      );
      dataSource.onOpponentExit?.call(dataSource.serverState!);
    });

    socket.on("game_finished", (data) {
      final winner = Player.fromJson(SocketUtils.convertToJSData(data));
      dataSource.onGameFinished?.call(winner);
    });

    socket.on("player_exit", (_) => dataSource.onPlayerExit?.call());
  }

  void _requestGameState(GameMode mode, String? gameId) {
    socket.emit("request_game_state", {
      "gameMode": mode.name,
      "gameId": gameId ?? "",
    });
  }
}
