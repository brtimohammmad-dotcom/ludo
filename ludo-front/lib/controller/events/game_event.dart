import 'package:ludo/controller/game-controller/game_controller.dart';

abstract class GameEvent {
  void execute(GameController controller);
}
