import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'game_event.dart';

class TimesUpEvent implements GameEvent {
  final String currentTurn;
  final String turnStatus;
  final List<dynamic> playersStatus;

  TimesUpEvent({
    required this.currentTurn,
    required this.turnStatus,
    required this.playersStatus,
  });

  factory TimesUpEvent.fromJson(Map<String, dynamic> json) {
    return TimesUpEvent(
      currentTurn: json['currentTurn'] as String,
      turnStatus: json['turnStatus'] as String,
      playersStatus: json['playersStatus'] as List<dynamic>,
    );
  }

  @override
  void execute(GameController controller) async {
    final currentGameState = controller.currentGameState;
    if (currentGameState?.serverState == null) return;

    // ۱. به‌روزرسانی وضعیت بازیکنان (غیبت‌ها و وضعیت آنلاین/آفلاین) در لیست قدیمی
    final updatedPlayers = currentGameState!.serverState!.players.map((player) {
      // پیدا کردن دیتای جدید این بازیکن از لیستی که سرور فرستاده
      final statusUpdate = playersStatus.firstWhere(
            (status) => status['color'] == player.color?.name,
        orElse: () => null,
      );

      if (statusUpdate != null) {
        // ایجاد یک نمونه جدید از بازیکن با مقادیر آپدیت شده
        return player.copyWith(
          playerStatus: PlayerStatus.values.byName(statusUpdate['playerStatus'] as String),
          numberOfAbsences: statusUpdate['number_of_absences'] as int,
        );
      }
      return player;
    }).toList();

    // ۲. ایجاد سرور استیت جدید با نوبت، وضعیت جدید و لیست بازیکنان آپدیت شده
    final finalState = currentGameState.serverState!.copyWith(
      currentTurn: PlayerColor.values.byName(currentTurn),
      turnStatus: TurnStatus.values.byName(turnStatus),
      players: updatedPlayers,
    );

    controller.updateState(controller.currentGameState?.copyWith(serverState: finalState));
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