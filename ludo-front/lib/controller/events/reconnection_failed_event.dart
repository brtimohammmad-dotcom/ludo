import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class ReconnectionFailedEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.animationController?.stop();
    controller.onReconnectionFailed?.call();
  }
}
