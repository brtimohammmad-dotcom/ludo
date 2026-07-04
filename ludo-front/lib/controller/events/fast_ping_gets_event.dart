import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class FastPingGetsEvent implements GameEvent{
  @override
  void execute(GameController controller) {
    controller.onFastPingGets?.call();
  }
}