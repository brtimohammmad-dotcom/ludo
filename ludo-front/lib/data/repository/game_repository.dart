import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/domain/model/token.dart';

class GameRepository {
  final SocketDataSource dataSource;

  GameRepository(this.dataSource);

  void connect() {
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
}
