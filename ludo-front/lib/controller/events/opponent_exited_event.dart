import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';

class OpponentExitedEvent implements GameEvent {
  final int userId;

  OpponentExitedEvent({required this.userId});

  factory OpponentExitedEvent.fromJson(Map<String, dynamic> data) {
    return OpponentExitedEvent(userId: data["userId"] as int);
  }

  @override
  void execute(GameController controller) {
    final currentState = controller.currentGameState?.serverState;
    final correctPlayers = currentState?.players
        .map(
          (p) => p.userId == userId
              ? p.copyWith(playerStatus: PlayerStatus.offline)
              : p,
        )
        .toList();
    final correctServerState = currentState?.copyWith(players: correctPlayers);
    controller.updateState(
      controller.currentGameState?.copyWith(serverState: correctServerState),
    );
  }
}
