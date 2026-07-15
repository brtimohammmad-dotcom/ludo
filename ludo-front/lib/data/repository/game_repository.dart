import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

class GameRepository {
  final SocketDataSource dataSource;

  GameRepository(this.dataSource);

  void connect(GameType type, String? gameId) {
    dataSource.connect(type, gameId);
  }

  void startGame(int numberOfPlayers, GameType gameType, GameLevel gameLevel) {
    dataSource.joinGame(numberOfPlayers,gameType,gameLevel);
  }

  void sendEmoji(String emojiName) {
    dataSource.sendEmoji(emojiName);
  }

  void rollDice() {
    dataSource.rollDice();
  }

  void moveToken(Token liveToken) {
    dataSource.moveToken(liveToken);
  }

  void getLeaderBoardList() {
    dataSource.getLeaderBoardList();
  }

  void exitGame() {
    dataSource.exitGame();
  }

  void getFastPing() {
    dataSource.getFastPing();
  }

  void claimDailyReward() {
    dataSource.claimDailyReward();
  }

  void resumeReconnection() {
    dataSource.resumeReconnection();
  }
}
