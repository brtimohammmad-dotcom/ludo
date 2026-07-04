import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'game_event.dart';

class DiceRolledEvent implements GameEvent {
  final int diceValue;
  final String? turnStatus;
  final String? currentTurn;

  DiceRolledEvent({required this.diceValue, this.turnStatus, this.currentTurn});

  factory DiceRolledEvent.fromJson(Map<String, dynamic> json) {
    return DiceRolledEvent(
      diceValue: json['last_dice_value'] as int,
      turnStatus: json['turn_status'] as String?,
      currentTurn: json['current_turn'] as String?,
    );
  }

  @override
  void execute(GameController controller) async {
    final currentGameState = controller.currentGameState;
    if (currentGameState?.serverState == null) return;

    // ۱. آپدیت استیت موقت برای انیمیشن تاس
    final finalState = currentGameState!.serverState!.copyWith(
      lastDiceValue: diceValue,
      turnStatus: turnStatus != null
          ? TurnStatus.values.byName(turnStatus!)
          : controller.currentGameState!.serverState!.turnStatus,
      currentTurn: currentTurn != null
          ? PlayerColor.values.byName(currentTurn!)
          : controller.currentGameState!.serverState!.currentTurn,
    );

    // ۲. اجرای انیمیشن تاس
    await controller.handleDiceRolled(finalState);
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
