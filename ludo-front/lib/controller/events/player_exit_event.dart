import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class PlayerExitEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    final gameState = controller.currentGameState;
    final serverState = gameState?.serverState;
    final livePlayer = gameState?.livePlayer;
    controller.updateState(
      controller.currentGameState?.copyWith(
        livePlayer: livePlayer?.copyWith(
          losses: serverState?.gameStatus == GameStatus.start
              ? livePlayer.losses + 1
              : livePlayer.losses,
        ),
        serverState: serverState?.copyWith(gameStatus: GameStatus.exit),
        gameStage: GameStage.joinStage
      ),
    );
    controller.stopLoading('cancel_game');
    controller.stopLoading('exit_game');
  }
}
