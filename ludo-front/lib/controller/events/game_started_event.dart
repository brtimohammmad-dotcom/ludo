import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class GameStartedEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    controller.updateState(
      controller.currentGameState!.copyWith(
        serverState: controller.currentGameState!.serverState!.copyWith(
          gameStatus: GameStatus.start,
        ),
      ),
    );
    controller.animationController?.forward();
    final isMyTurn =
        controller.currentGameState?.serverState?.currentTurn ==
            controller.currentGameState!.livePlayer!.color &&
            controller.currentGameState?.serverState?.gameStatus ==
                GameStatus.start;
    if (isMyTurn) {
      controller.playSfx("assets/audio/sound-effect/current_turn_sound.wav");
    }
  }
}
