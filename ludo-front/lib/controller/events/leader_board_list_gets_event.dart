import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class LeaderBoardListGetsEvent implements GameEvent {
  final Map<String, dynamic> data;

  LeaderBoardListGetsEvent({required this.data});

  @override
  void execute(GameController controller) {
    controller.updateLeaderBoard(data);
    controller.updateState(
      controller.currentGameState?.copyWith(gameStage: GameStage.leaderBoard),
    );
    controller.stopLoading("leader_board_loading");
  }
}
