import 'package:flutter/cupertino.dart';
import 'package:ludo/data/data-source/socket_data_source.dart';

import 'package:ludo/domain/model/token.dart';

class GameRepository {
  final SocketDataSource dataSource = SocketDataSource();

  void onConnect({required int gameMode}) {
    dataSource.connectToGame(gameMode: gameMode);
  }

  void rollDice() {
    dataSource.rollDice();
  }

  void moveToken(Token liveToken) {
    dataSource.moveToken(liveToken);
  }

  void exitGame(int telegramId) {
    dataSource.exitGame(telegramId);
  }
  void demoDisconnectAndConnect(){
    dataSource.demoDisconnectAndConnect();
  }

  Future<void> dispose() async {
    debugPrint("🧹 GameRepository dispose called");

    if (dataSource.socket != null) {
      // فرستادن سیگنال خروج
      if (dataSource.socket!.connected) {
        dataSource.socket!.disconnect();
      }
      dataSource.socket!.close();
      dataSource.socket!.clearListeners();
      dataSource.socket = null;
    }

    // پاک کردن کال‌بک‌ها
    dataSource.onStateUpdate = null;
    dataSource.onTimesUp = null;
    dataSource.onGameFinished = null;
    dataSource.onPlayerUpdate = null;
    dataSource.onTokenMoved = null;
    dataSource.onDiceRolled = null;
  }
}
