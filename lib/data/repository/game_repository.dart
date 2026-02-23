import 'package:ludo/data/data-source/socket_data_source.dart';

import 'package:ludo/domain/model/token.dart';

class GameRepository {
   final SocketDataSource dataSource=SocketDataSource();



  void onConnect() {
    dataSource.connectToGame();
  }

  void rollDice() {
    dataSource.rollDice();
  }

  void moveToken(Token liveToken) {
    dataSource.moveToken(liveToken);
  }
  
  void dispose() {
    dataSource.disconnect();
  }
}
