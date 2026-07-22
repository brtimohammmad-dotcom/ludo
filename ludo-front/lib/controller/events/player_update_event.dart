import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class PlayerUpdateEvent implements GameEvent {
  final Player newPlayer;

  const PlayerUpdateEvent({required this.newPlayer});

  // ۱. تبدیل دیتای خام بک‌آند به مدل Player
  factory PlayerUpdateEvent.fromJson(Map<String, dynamic> data) {
    debugPrint(data.toString());
    return PlayerUpdateEvent(newPlayer: Player.fromJson(data));
  }

  @override
  void execute(GameController controller) {
    controller.updateState(
      GameState(
        serverState: controller.currentGameState?.serverState,
        livePlayer: newPlayer,
      ),
    );

  }
}
