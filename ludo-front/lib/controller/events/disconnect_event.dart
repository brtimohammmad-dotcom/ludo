import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class DisconnectEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.clearAllLoadings();
    controller.animationController?.stop();
    controller.updateState(
      controller.currentGameState?.copyWith(
        connectionStatus: ConnectionStatus.reconnecting,
      ),
    );

  }
}
