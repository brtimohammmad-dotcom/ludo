import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';

class PlayerJoinedEvent implements GameEvent {
  final Player newPlayer;

  const PlayerJoinedEvent({required this.newPlayer});

  // ۱. تبدیل دیتای خام بک‌آند به مدل Player
  factory PlayerJoinedEvent.fromJson(Map<String, dynamic> data) {
    return PlayerJoinedEvent(newPlayer: Player.fromJson(data));
  }

  @override
  void execute(GameController controller) {
    // اگر هنوز استیت اصلی سرور لود نشده باشد، عملیات را متوقف کن
    if (controller.currentGameState?.serverState == null) return;

    final currentServerState = controller.currentGameState!.serverState!;

    // جهت اطمینان: اگر بازیکن از قبل در لیست بود (مثلاً به خاطر تاخیر شبکه دو بار ایونت آمد) اضافه نکن
    final isAlreadyInGame = currentServerState.players.any(
      (p) => p.userId == newPlayer.userId,
    );
    if (isAlreadyInGame) {
      final correctPlayers = currentServerState.players
          .map(
            (p) => p.userId == newPlayer.userId
                ? p.copyWith(playerStatus: PlayerStatus.online)
                : p,
          )
          .toList();
      final correctState = currentServerState.copyWith(players: correctPlayers);
      controller.updateState(
        controller.currentGameState!.copyWith(serverState: correctState),
      );
      return;
    }

    // ۲. اضافه کردن بازیکن جدید به لیست بازیکنان فعلی
    final updatedPlayers = List<Player>.from(currentServerState.players)
      ..add(newPlayer);

    // ۳. به روز رسانی استیت کلی (GameState) با استفاده از copyWith
    controller.updateState(
      controller.currentGameState!.copyWith(
        serverState: currentServerState.copyWith(players: updatedPlayers),
      ),
    );
  }
}
