import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/domain/model/token.dart';

class GameRepository {
  final SocketDataSource dataSource = SocketDataSource();

  void onConnect() {
    dataSource.connectToGame();
  }

  void startGame(int gameMode) {
    dataSource.joinGame(gameMode);
  }

  void rollDice() {
    dataSource.rollDice();
  }

  void moveToken(Token liveToken) {
    dataSource.moveToken(liveToken);
  }

  void exitGame() {
    dataSource.exitGame();
  }

  void demoDisconnectAndConnect() {
    dataSource.demoDisconnectAndConnect();
  }


}
