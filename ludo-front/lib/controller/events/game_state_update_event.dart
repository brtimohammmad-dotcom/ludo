import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'dart:js_interop';

@JS('onGameConnected')
external void onGameConnected();

class GameStateUpdateEvent implements GameEvent {
  final ServerState updatedState;

  const GameStateUpdateEvent({required this.updatedState});

  // متد factory دیتای خام را می‌گیرد و با استفاده از خود ServerState.fromJson پارس می‌کند
  factory GameStateUpdateEvent.fromJson(Map<String, dynamic> data) {
    return GameStateUpdateEvent(updatedState: ServerState.fromJson(data));
  }

  @override
  void execute(GameController controller) {
    final livePlayer = updatedState.players.firstWhere(
      (p) => p.userId == controller.currentGameState?.livePlayer?.userId,
      orElse: () => updatedState.players.first,
    );

    controller.updateState(
      GameState(
        serverState: updatedState,
        livePlayer: livePlayer,
        gameStage: GameStage.boardStage,
      ),
    );
    controller.onGameReady?.call();
    onGameConnected();
    controller.playMenuMusic();
  }
}
