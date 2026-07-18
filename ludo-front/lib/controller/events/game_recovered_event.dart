import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'dart:js_interop';

@JS('onGameConnected')
external void onGameConnected();

class GameRecoveredEvent implements GameEvent {
  final ServerState recoveredState;

  const GameRecoveredEvent({required this.recoveredState});

  // متد factory دیتای خام را می‌گیرد و با استفاده از خود ServerState.fromJson پارس می‌کند
  factory GameRecoveredEvent.fromJson(Map<String, dynamic> data) {
    return GameRecoveredEvent(recoveredState: ServerState.fromJson(data));
  }

  @override
  void execute(GameController controller) {
    // پیدا کردن لایو پلیر (خود بازیکن) در استیت جدید
    final livePlayer = recoveredState.players.firstWhere(
      (p) => p.userId == controller.currentGameState?.livePlayer?.userId,
      orElse: () => recoveredState.players.first,
    );

    // جایگزینی آنی و بدون انیمیشن کل استیت بازی برای هماهنگی با سرور
    controller.updateState(
      GameState(
        serverState: recoveredState,
        livePlayer: livePlayer,
        gameStage: GameStage.boardStage,
      ),
    );
    onGameConnected();
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
