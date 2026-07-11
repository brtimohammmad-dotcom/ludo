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
    final double fullWidth = boardSize * 0.22;
    if (playerIndex == -1) {
      return SizedBox(width: fullWidth, height: boardSize * 0.06);
    }

    final gameStatus = ref.watch(gameControllerProvider.select((s) => s?.serverState?.gameStatus));
    if (gameStatus == null) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    final playerData = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          final p = players[playerIndex];
          return (
          username: p.username,
          status: p.playerStatus,
          absences: p.numberOfAbsences,
          coin: p.coin,
          exists: true,
          );
        }
        return (username: '', status: PlayerStatus.online, absences: 0, coin: 0, exists: false);
      }),
    );

    final totalPlayers = ref.watch(gameControllerProvider.select((s) => s?.serverState?.numberOfPlayers ?? 2));
    final playerColor = recognitionPlayerColor(playerIndex, totalPlayers);

    final isMyTurn = ref.watch(gameControllerProvider.select((s) => s?.serverState?.currentTurn == playerColor));
    final turnStatus = ref.watch(gameControllerProvider.select((s) => s?.serverState?.currentTurn == playerColor ? s?.serverState?.turnStatus : null));

    final bool isCurrentTurn = isMyTurn && gameStatus == GameStatus.start && turnStatus != TurnStatus.waitingForAnimate;
    final animationController = ref.watch(gameControllerProvider.notifier).animationController;

    final activeBorderColor = playerColor == PlayerColor.red
        ? Colors.redAccent
        : playerColor == PlayerColor.green
        ? Colors.greenAccent
        : playerColor == PlayerColor.yellow
        ? Colors.amberAccent
        : Colors.cyanAccent;

    Color usernameTimerBoxColor() {
      if (gameStatus != GameStatus.start) return Colors.transparent;
      switch (playerData.absences) {
        case 1: return const Color(0x4DFFEB3B);
        case 2: return const Color(0x4DFFC107);
        default: return const Color(0x33FFFFFF);
      }
    }

    final borderRadius = BorderRadius.circular(boardSize * 0.1);

    return Container(
      width: fullWidth,
      height: boardSize * 0.06,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isCurrentTurn ? const Color(0x1FFFFFFF) : const Color(0x8A000000), // سبک‌سازی با حذف بلور داینامیک
        border: Border.all(
          color: isCurrentTurn ? activeBorderColor.withValues(alpha: 0.5) : Colors.white10,
          width: 1.2,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (isCurrentTurn && animationController != null)
            _SolidTimerProgressLine(
              fullWidth: fullWidth,
              boardSize: boardSize,
              barColor: usernameTimerBoxColor(),
              borderRadius: borderRadius,
              controller: animationController,
            ),
          Center(
            child: _PlayerInfoRow(
              playerData: playerData,
              barHeight: barHeight,
              boardSize: boardSize,
              totalPlayers: totalPlayers,
              isCurrentTurn: isCurrentTurn,
              playerColor: playerColor,
              playerIndex: playerIndex,
              isMyTurn: isMyTurn,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidTimerProgressLine extends StatelessWidget {
  const _SolidTimerProgressLine({
    required this.fullWidth,
    required this.boardSize,
    required this.barColor,
    required this.borderRadius,
    required this.controller,
  });

  final double fullWidth;
  final double boardSize;
  final Color barColor;
  final BorderRadius borderRadius;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SizedBox(
            width: fullWidth * (1 - controller.value),
            height: boardSize * 0.06,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: borderRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerInfoRow extends StatelessWidget {
  const _PlayerInfoRow({
    required this.playerData,
    required this.barHeight,
    required this.boardSize,
    required this.totalPlayers,
    required this.isCurrentTurn,
    required this.playerColor,
    required this.playerIndex,
    required this.isMyTurn,
  });

  final dynamic playerData;
  final double barHeight;
  final double boardSize;
  final int totalPlayers;
  final bool isCurrentTurn;
  final PlayerColor playerColor;
  final int playerIndex;
  final bool isMyTurn;

  @override
  Widget build(BuildContext context) {
    if (!playerData.exists) {
      return Text(
        "waiting...",
        style: TextStyle(
          color: const Color(0x4DFFFFFF),
          fontSize: barHeight * 0.2,
        ),
      );
    }

    if (playerData.status != PlayerStatus.online) {
      return Text(
        "out",
        style: TextStyle(
          color: const Color(0x4DFFFFFF),
          fontSize: barHeight * 0.36,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(boardSize * 0.01),
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
                color: playerUserNameBoxColor(
                  playerIndex: playerIndex,
                  numberOfPlayers: totalPlayers,
                  currentTurn: isCurrentTurn ? playerColor : null,
                ),
                fontSize: barHeight * 0.26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: boardSize * 0.005),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: boardSize * 0.01,
              vertical: boardSize * 0.005,
            ),
            decoration: BoxDecoration(
              color: const Color(0x33000000),
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
                  playerData.coin.toString(),
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
  }
}