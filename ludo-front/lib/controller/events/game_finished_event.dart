import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';

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
    if (controller.currentGameState!.gameStage != GameStage.boardStage) {
      controller.updateState(
        controller.currentGameState!.copyWith(gameStage: GameStage.joinStage),
      );
      return;
    }
    controller.animationController?.stop();

    controller.updateState(
      controller.currentGameState!.copyWith(
        serverState: controller.currentGameState!.serverState!.copyWith(
          winner: newPlayer,
        ),
      ),
    );

    if (!controller.isGameFinishedHandled &&
        controller.onGameFinished != null) {
      controller.isGameFinishedHandled = true;
      controller.onGameFinished!();
    }
  }
}
