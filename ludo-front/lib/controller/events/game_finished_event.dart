import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class GameFinishedEvent implements GameEvent {
  final Player newPlayer;

  const GameFinishedEvent({required this.newPlayer});

  // ۱. تبدیل دیتای خام بک‌آند به مدل Player
  factory GameFinishedEvent.fromJson(Map<String, dynamic> data) {
    return GameFinishedEvent(newPlayer: Player.fromJson(data));
  }

  @override
  void execute(GameController controller) {
    if (controller.currentGameState == null) return;
    final livePlayer = controller.currentGameState?.livePlayer;
    final isWinner = livePlayer?.userId == newPlayer.userId;
    if (controller.currentGameState!.gameStage != GameStage.boardStage) {
      controller.updateState(
        controller.currentGameState!.copyWith(
          gameStage: GameStage.joinStage,
          livePlayer: livePlayer?.copyWith(
            coin: isWinner
                ? livePlayer.coin + controller.currentGameState.winPrice()
                : livePlayer.coin,
          ),
        ),
      );
      return;
    }
    controller.animationController?.stop();
    controller.updateState(
      controller.currentGameState!.copyWith(
        livePlayer: livePlayer?.copyWith(
          coin: isWinner
              ? livePlayer.coin + controller.currentGameState.winPrice()
              : livePlayer.coin,
        ),
        serverState: controller.currentGameState!.serverState!.copyWith(
          winner: newPlayer,
          gameStatus: GameStatus.finished,
          turnStatus: null,
        ),
      ),
    );
  }
}
