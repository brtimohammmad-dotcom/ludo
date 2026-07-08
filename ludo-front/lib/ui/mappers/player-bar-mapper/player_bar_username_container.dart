import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
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
    final double fullWidth = boardSize * 0.22; // کمی عرض را بیشتر کردیم تا سکه هم جا شود
    if (playerIndex == -1) {
      return SizedBox(width: fullWidth, height: boardSize * 0.06);
    }

    // ۱. تعداد کل بازیکنان
    final totalPlayers = ref.watch(
      gameControllerProvider.select(
            (s) => s?.serverState?.numberOfPlayers ?? 2,
      ),
    );
    final playerColor = recognitionPlayerColor(playerIndex, totalPlayers);

    // ۲. بررسی نوبت
    final isMyTurn = ref.watch(
      gameControllerProvider.select(
            (s) => s?.serverState?.currentTurn == playerColor,
      ),
    );

    // ۳. گوش دادن به وضعیت نوبت فقط زمانی که نوبت این بازیکن است
    final turnStatus = ref.watch(
      gameControllerProvider.select((s) {
        if (s?.serverState?.currentTurn == playerColor) {
          return s?.serverState?.turnStatus;
        }
        return null;
      }),
    );

    // ۴. وضعیت کلی بازی
    final gameStatus = ref.watch(
      gameControllerProvider.select((s) => s?.serverState?.gameStatus),
    );

    // ۵. دریافت اطلاعات پایه بازیکن
    final playerData = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          final p = players[playerIndex];
          return (
          username: p.username,
          status: p.playerStatus,
          absences: p.numberOfAbsences,
          exists: true,
          );
        }
        return (
        username: '',
        status: PlayerStatus.online,
        absences: 0,
        exists: false,
        );
      }),
    );

    final playerCoin = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          return players[playerIndex].coin;
        }
        return 0;
      }),
    );

    final gameController = ref.read(gameControllerProvider.notifier);

    if (gameStatus == null) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    debugPrint("--build player bar for index $playerIndex--");

    final isCurrentTurn =
        isMyTurn &&
            gameStatus == GameStatus.start &&
            turnStatus != TurnStatus.waitingForAnimate;

    Widget usernameStatusPicker() {
      if (!playerData.exists) {
        return Text(
          "waiting...",
          style: TextStyle(
            inherit: true,
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: barHeight * 0.2,
          ),
        );
      }

      if (playerData.status == PlayerStatus.online) {
        final currentTurnField = isCurrentTurn ? playerColor : null;

        return Padding(
          padding:  EdgeInsets.all(boardSize*0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  playerData.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    inherit: true,
                    color: playerUserNameBoxColor(
                      playerIndex: playerIndex,
                      numberOfPlayers: totalPlayers,
                      currentTurn: currentTurnField,
                    ),
                    fontSize: barHeight * 0.26,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      isMyTurn
                          ? const BoxShadow(
                        color: Colors.black54,
                        offset: Offset(-0.5, 0.5),
                        blurRadius: 0.2,
                      )
                          : const BoxShadow(color: Colors.transparent),
                    ],
                  ),
                ),
              ),
               SizedBox(width: boardSize*0.005),

              // 🪙 مینی‌باکس نمایش سکه (همیشه ثابت و نمایان می‌مونه)
              Container(
                padding: EdgeInsets.symmetric(horizontal: boardSize * 0.01, vertical: boardSize * 0.005),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: boardSize * 0.02,
                    ),
                    SizedBox(width: boardSize * 0.005),
                    Text(
                      playerCoin.toString(),
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: boardSize * 0.02,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else {
        return Text(
          "out",
          style: TextStyle(
            inherit: true,
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: barHeight * 0.36,
          ),
        );
      }
    }

    Color usernameTimerBoxColor() {
      if (gameStatus != GameStatus.start) {
        return !playerData.exists ? Colors.transparent : Colors.white24;
      }

      switch (playerData.absences) {
        case 0:
          return Colors.white.withValues(alpha: 0.2);
        case 1:
          return Colors.yellow.withValues(alpha: 0.3);
        case 2:
          return Colors.red.withValues(alpha: 0.3);
        default:
          return Colors.transparent;
      }
    }

    final borderRadius = BorderRadius.circular(boardSize * 0.1);

    final activeBorderColor = playerColor == PlayerColor.red
        ? Colors.redAccent
        : playerColor == PlayerColor.green
        ? Colors.greenAccent
        : playerColor == PlayerColor.yellow
        ? Colors.amberAccent
        : Colors.cyanAccent;

    return Container(
      width: fullWidth,
      height: boardSize * 0.06,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: isCurrentTurn
            ? [
          BoxShadow(
            color: activeBorderColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: isCurrentTurn
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.25),
              border: Border.all(
                color: isCurrentTurn
                    ? activeBorderColor.withValues(alpha: 0.4)
                    : Colors.white10,
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                if (gameController.animationController != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedBuilder(
                      animation: gameController.animationController!,
                      builder: (context, child) {
                        final double targetWidth = isCurrentTurn
                            ? fullWidth * (1 - gameController.animationController!.value)
                            : 0.0;

                        return Container(
                          width: targetWidth,
                          height: boardSize * 0.06,
                          decoration: BoxDecoration(
                            color: usernameTimerBoxColor(),
                            borderRadius: borderRadius,
                          ),
                        );
                      },
                    ),
                  ),
                Center(child: usernameStatusPicker()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}