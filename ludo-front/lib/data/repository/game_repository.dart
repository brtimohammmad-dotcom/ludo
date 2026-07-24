import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

class GameRepository {
  final SocketDataSource dataSource;

  GameRepository(this.dataSource);

  void connect() {
    dataSource.connect();
  }

  void requestGameState() {
    dataSource.requestGameState();
  }

  void startGame(
    int numberOfPlayers,
    GameType gameType,
    GameLevel gameLevel,
    Function(dynamic response)? onAck,
  ) {
    dataSource.joinGame(
      numberOfPlayers: numberOfPlayers,
      gameType: gameType,
      gameLevel: gameLevel,
      onAck: onAck,
    );
  }

  void sendEmoji(String emojiName) {
    dataSource.sendEmoji(emojiName);
  }

  void rollDice(Function(dynamic response)? onAck) {
    dataSource.rollDice(onAck: onAck);
  }

  void moveToken(Token liveToken, Function(dynamic response)? onAck) {
    dataSource.moveToken(liveToken, onAck: onAck);
  }

  void getLeaderBoardList(Function(dynamic response)? onAck) {
    dataSource.getLeaderBoardList(onAck: onAck);
  }

  void exitGame(Function(dynamic response)? onAck) {
    dataSource.exitGame(onAck: onAck);
  }

  void getFastPing() {
    dataSource.getFastPing();
  }

  void claimDailyReward(Function(dynamic response)? onAck) {
    dataSource.claimDailyReward(onAck: onAck);
  }

  void resumeReconnection() {
    dataSource.resumeReconnection();
  }
}
