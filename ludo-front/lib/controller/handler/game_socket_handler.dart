import 'package:ludo/controller/events/game_event_factory.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class GameSocketHandler {
  final GameController controller;

  GameSocketHandler(this.controller);

  void init() {
    final ds = controller.gameRepository.dataSource;
    ds.onGameEventReceived = (String eventName, Map<String, dynamic> data) {
      final event = GameEventFactory.create(eventName, data);
      if (event != null) {
        event.execute(controller);
      }
    };

  }


}
