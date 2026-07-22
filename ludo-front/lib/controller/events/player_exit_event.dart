import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class PlayerExitEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.updateState(
      controller.currentGameState?.copyWith(
        serverState: controller.currentGameState?.serverState?.copyWith(
          gameStatus: GameStatus.exit,
        ),
      ),
    );
    controller.stopLoading('cancel_game');
    controller.stopLoading('exit_game');

  }
}
