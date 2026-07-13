import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:telegram_web_app/telegram_web_app.dart';
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
        initData = {"first_name": "امیرمحمد براتی", "id": 18};
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
    socket.on(
      "not_in_game",
      (_) => dataSource.onGameEventReceived?.call('not_in_game', {}),
    );

    socket.on("in_another_game", (_) {
      dataSource.onGameEventReceived?.call('in_another_game', {});
      _requestGameState(mode, gameId);
    });

    socket.on(
      "fast_ping_gets",
      (_) => dataSource.onGameEventReceived?.call('fast_ping_gets', {}),
    );

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

      dataSource.onGameEventReceived?.call("player_update", clean);

      if (!dataSource.playerInitialized.isCompleted) {
        dataSource.playerInitialized.complete();
      }
      _requestGameState(mode, gameId);
    });

    // --- رویدادهای اصلی گیم‌پلی ---
    socket.on("game_state_update", (data) async {
      await dataSource.playerInitialized.future;
      final cleanData = SocketUtils.convertToJSData(data);

      dataSource.onGameEventReceived?.call("game_state_update", cleanData);
    });
    socket.on("game_started", (data) {
      final cleanData = SocketUtils.convertToJSData(data);

      dataSource.onGameEventReceived?.call("game_started", cleanData);
    });

    socket.on("leader_board_list_gets",(data){
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("leader_board_list_gets", cleanData);
    });

    socket.on("player_joined", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("player_joined", cleanData);
    });

    socket.on("game_recovered", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("game_recovered", cleanData);
    });

    socket.on("dice_rolled", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("dice_rolled", cleanData);
    });

    socket.on("times_up", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("times_up", cleanData);
    });

    socket.on("token_moved", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      // اسم ایونت اصلاح شد به token_moved
      dataSource.onGameEventReceived?.call("token_moved", cleanData);
    });

    socket.on("opponent_exit", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("opponent_exit", cleanData);
    });

    socket.on("game_finished", (data) {
      final cleanData = SocketUtils.convertToJSData(data);

      dataSource.onGameEventReceived?.call('game_finished', cleanData);
    });

    socket.on(
      "player_exit",
      (_) => dataSource.onGameEventReceived?.call('player_exit', {}),
    );

    socket.on("insufficient_coin", (_) {
      dataSource.onGameEventReceived?.call('insufficient_coin', {});
    });

    socket.on("daily_reward_claimed", (data) {
      final cleanData = SocketUtils.convertToJSData(data);
      dataSource.onGameEventReceived?.call("daily_reward_claimed", cleanData);
    });
    socket.on("already_claimed_daily_reward", (data) {
      if (TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert("You are already claimed!", () {});
      }
    });
  }

  void _requestGameState(GameMode mode, String? gameId) {
    socket.emit("request_game_state", {
      "gameMode": mode.name,
      "gameId": gameId ?? "",
    });
  }
}
