import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/mappers/player-bar-mapper/player_bar_utils.dart';

class PlayerBarUsernameContainer extends ConsumerWidget {
  const PlayerBarUsernameContainer({
    super.key,
    required this.boardSize,
    required this.playerIndex,
    required this.barHeight,
  });

  final double boardSize;
  final int playerIndex;
  final double barHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerIndex == -1) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    // 🟢 ۱. فقط گوش دادن به وضعیت بازی (شروع، پایان و...) و تعداد کل بازیکنان
    final gameStatus = ref.watch(
      gameControllerProvider.select((s) => s?.serverState?.gameStatus),
    );
    final turnStatus = ref.watch(
      gameControllerProvider.select((s) => s?.serverState?.turnStatus),
    );
    final totalPlayers = ref.watch(
      gameControllerProvider.select(
        (s) => s?.serverState?.numberOfPlayers ?? 2,
      ),
    );

    // 🟢 ۲. فقط گوش دادن به نوبت فعلی
    final currentTurn = ref.watch(
      gameControllerProvider.select((s) => s?.serverState?.currentTurn),
    );

    // 🟢 ۳. فقط گوش دادن به اطلاعات بازیکنِ همین ایندکس خاص (نه همه بازیکنان!)
    final player = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          return players[playerIndex];
        }
        return null;
      }),
    );

    // کنترلر انیمیشن را از روی کنترلر (بدون واچ کردن استیت) می‌خوانیم
    final gameController = ref.read(gameControllerProvider.notifier);

    // اگر هنوز دیتایی از سرور نیامده، یک باکس خالی بده
    if (gameStatus == null) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    debugPrint("--build player bar for index $playerIndex--");

    final playerColor = recognitionPlayerColor(playerIndex, totalPlayers);

    // محاسبه وضعیت نوبت این بازیکن
    final isCurrentTurn =
        currentTurn == playerColor &&
        gameStatus == GameStatus.start &&
        turnStatus != TurnStatus.waitingForAnimate;

    final double fullWidth = boardSize * 0.29;

    // متد کمکی داخلی برای نمایش نام کاربری یا وضعیت
    Widget usernameStatusPicker() {
      if (player == null) {
        return Text(
          "waiting...",
          style: TextStyle(
            inherit: true,
            color: Colors.black45.withAlpha(30),
            fontSize: barHeight * 0.36,
          ),
        );
      }

      if (player.playerStatus == PlayerStatus.online) {
        return Text(
          player.username,
          style: TextStyle(
            inherit: true,
            color: playerUserNameBoxColor(
              playerIndex: playerIndex,
              numberOfPlayers: totalPlayers, // متغیری که بالاتر واچ شده
              currentTurn: currentTurn, // متغیری که بالاتر واچ شده
            ),
            fontSize: barHeight * 0.4,
            shadows: [
              currentTurn == playerColor
                  ? const BoxShadow(
                      color: Colors.black54,
                      offset: Offset(-0.5, 0.5),
                      blurRadius: 0.2,
                    )
                  : const BoxShadow(color: Colors.transparent),
            ],
          ),
        );
      } else {
        return Text(
          "out",
          style: TextStyle(
            inherit: true,
            color: Colors.black45.withAlpha(30),
            fontSize: barHeight * 0.36,
          ),
        );
      }
    }

    Color usernameTimerBoxColor() {
      if (gameStatus != GameStatus.start) {
        return player == null ? Colors.transparent : Colors.white;
      }

      switch (player?.numberOfAbsences ?? 0) {
        case 0:
          return Colors.white;
        case 1:
          return Colors.yellow.shade200;
        case 2:
          return Colors.red.shade200;
        default:
          return Colors.transparent;
      }
    }

    return Container(
      width: fullWidth,
      height: boardSize * 0.06,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(boardSize * 0.1),
        color: Colors.blueGrey,
        boxShadow: const [
          BoxShadow(color: Colors.black38, offset: Offset(-1, 3)),
        ],
      ),
      child: Stack(
        children: [
          if (gameController.animationController != null)
            Align(
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: gameController.animationController!,
                builder: (context, child) {
                  final double targetWidth = isCurrentTurn
                      ? fullWidth *
                            (1 - gameController.animationController!.value)
                      : 0.0;

                  return Container(
                    width: targetWidth,
                    height: boardSize * 0.06,
                    decoration: BoxDecoration(
                      color: usernameTimerBoxColor(),
                      borderRadius: BorderRadius.circular(boardSize * 0.1),
                    ),
                  );
                },
              ),
            ),
          Center(child: usernameStatusPicker()),
        ],
      ),
    );
  }
}
