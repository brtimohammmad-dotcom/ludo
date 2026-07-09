import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';

class GameRepository {
  final SocketDataSource dataSource;

  GameRepository(this.dataSource);

  void connect(GameMode mode,String? gameId) {
    dataSource.connect(mode,gameId);
  }

  void startGame(int numberOfPlayers) {
    dataSource.joinGame(numberOfPlayers);
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
  void getFastPing(){
    dataSource.getFastPing();
  }

  void claimDailyReward() {
    dataSource.claimDailyReward();
  }
}
