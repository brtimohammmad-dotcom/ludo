import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'dart:js_interop';

@JS('onGameConnected')
external void onGameConnected();

class NotInGameEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.updateState(
      controller.currentGameState?.copyWith(gameStage: GameStage.joinStage),
    );
    onGameConnected();
    controller.playMenuMusic();
  }
}
