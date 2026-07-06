import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class OpponentExitedEvent implements GameEvent {
  final int userId;

  OpponentExitedEvent({required this.userId});

  factory OpponentExitedEvent.fromJson(Map<String, dynamic> data) {
    return OpponentExitedEvent(userId: data["userId"] as int);
  }

  @override
  void execute(GameController controller) {
    final List<Player>? correctPlayers;
    final currentState = controller.currentGameState?.serverState;

    correctPlayers = currentState?.gameStatus == GameStatus.start
        ? currentState?.players
              .map(
                (p) => p.userId == userId
                    ? p.copyWith(playerStatus: PlayerStatus.offline)
                    : p,
              )
              .toList()
        : currentState?.players.where((p) => p.userId != userId).toList();
    final correctServerState = currentState?.copyWith(players: correctPlayers);
    controller.updateState(
      controller.currentGameState?.copyWith(serverState: correctServerState),
    );
  }
}
