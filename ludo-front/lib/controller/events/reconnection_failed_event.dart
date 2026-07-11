import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class ReconnectionFailedEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.animationController?.stop();
    controller.updateState(
      controller.currentGameState?.copyWith(
        connectionStatus: ConnectionStatus.disconnected,
      ),
    );
    final currentStage = controller.currentGameState?.gameStage;

    if (currentStage != GameStage.connectionStage && currentStage != null) {
      return;
    }
    controller.onReconnectionFailed?.call();
  }
}
