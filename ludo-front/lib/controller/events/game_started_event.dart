import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
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
    final state = controller.currentGameState?.serverState;
    final int reducedCoin = controller.currentGameState.reduceCoin();
    final newPlayers = state?.players
        .map(
          (p) => p.copyWith(
            coin: state.type == GameType.global ? p.coin - reducedCoin : p.coin,
          ),
        )
        .toList();
    final livePlayer = controller.currentGameState?.livePlayer;
    controller.updateState(
      controller.currentGameState?.copyWith(
        livePlayer: livePlayer?.copyWith(coin: livePlayer.coin - reducedCoin),
        serverState: state?.copyWith(players: newPlayers),
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
