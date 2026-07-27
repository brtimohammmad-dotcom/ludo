import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player-bar-elements/player_bar_utils.dart';
import 'package:ludo/ui/utils/avatar.dart';

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

    // ۱. فقط چک می‌کنیم بازیکن هست و آنلاینه یا نه (یک boolean ساده)
    final bool isPlayerActive = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          return players[playerIndex].playerStatus == PlayerStatus.online;
        }
        return false;
      }),
    );

    // اگر بازیکن آنلاین نباشه یا وجود نداشته باشه، مستقیم خالی برمی‌گردونیم
    if (!isPlayerActive) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    // ۲. محاسبه رنگ بازیکن بر اساس تعداد کل بازیکنان
    final totalPlayers = ref.watch(
      gameControllerProvider.select((s) => s?.serverState?.numberOfPlayers ?? 2),
    );
    final playerColor = recognitionPlayerColor(playerIndex, totalPlayers);
    final bool isAvatarOnLeft = playerColor == PlayerColor.red || playerColor == PlayerColor.blue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAvatarOnLeft) ...[
          _PlayerAvatar(playerIndex: playerIndex, boardSize: boardSize, playerColor: playerColor),
          SizedBox(width: boardSize * 0.015),
          _PlayerCardContent(
            fullWidth: fullWidth,
            boardSize: boardSize,
            barHeight: barHeight,
            playerIndex: playerIndex,
            playerColor: playerColor,
          ),
        ] else ...[
          _PlayerCardContent(
            fullWidth: fullWidth,
            boardSize: boardSize,
            barHeight: barHeight,
            playerIndex: playerIndex,
            playerColor: playerColor,
          ),
          SizedBox(width: boardSize * 0.015),
          _PlayerAvatar(playerIndex: playerIndex, boardSize: boardSize, playerColor: playerColor),
        ],
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// آواتار بازیکن
// -----------------------------------------------------------------------------
class _PlayerAvatar extends ConsumerWidget {
  const _PlayerAvatar({
    required this.playerIndex,
    required this.boardSize,
    required this.playerColor,
  });

  final int playerIndex;
  final double boardSize;
  final PlayerColor playerColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarUrl = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        return (players != null && players.length > playerIndex)
            ? players[playerIndex].avatarUrl
            : null;
      }),
    );

    final isCurrentTurn = ref.watch(
      gameControllerProvider.select((s) {
        return s?.serverState?.currentTurn == playerColor &&
            s?.serverState?.gameStatus == GameStatus.start;
      }),
    );

    final activeBorderColor = switch (playerColor) {
      PlayerColor.red => Colors.red,
      PlayerColor.green => Colors.green,
      PlayerColor.yellow => Colors.amber,
      PlayerColor.blue => Colors.cyan,
    };

    return UserAvatar(
      url: avatarUrl,
      size: boardSize * 0.06,
      borderColor: isCurrentTurn ? activeBorderColor : Colors.grey,
    );
  }
}

// -----------------------------------------------------------------------------
// کادر محتوای بازیکن (تایمر + نام + سکه)
// -----------------------------------------------------------------------------
class _PlayerCardContent extends ConsumerWidget {
  const _PlayerCardContent({
    required this.fullWidth,
    required this.boardSize,
    required this.barHeight,
    required this.playerIndex,
    required this.playerColor,
  });

  final double fullWidth;
  final double boardSize;
  final double barHeight;
  final int playerIndex;
  final PlayerColor playerColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // اطلاعات بازیکن برای نمایش متون
    final (username, coin, absences) = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        if (players != null && players.length > playerIndex) {
          final p = players[playerIndex];
          return (p.username, p.coin, p.numberOfAbsences);
        }
        return ('', 0, 0);
      }),
    );

    // وضعیت نوبت
    final (gameStatus, totalPlayers, isCurrentTurn) = ref.watch(
      gameControllerProvider.select((s) {
        final gStatus = s?.serverState?.gameStatus;
        final totalP = s?.serverState?.numberOfPlayers ?? 2;
        final myTurn = s?.serverState?.currentTurn == playerColor;
        final tStatus = myTurn ? s?.serverState?.turnStatus : null;

        final currentTurn = myTurn &&
            gStatus == GameStatus.start &&
            tStatus != TurnStatus.waitingForAnimate;

        return (gStatus, totalP, currentTurn);
      }),
    );

    final animationController = ref.watch(gameControllerProvider.notifier).animationController;

    final activeBorderColor = switch (playerColor) {
      PlayerColor.red => Colors.red,
      PlayerColor.green => Colors.green,
      PlayerColor.yellow => Colors.amber,
      PlayerColor.blue => Colors.cyan,
    };

    Color timerBoxColor() {
      if (gameStatus != GameStatus.start) return Colors.transparent;
      switch (absences) {
        case 1:
          return const Color(0xFFEAB308);
        case 2:
          return const Color(0xFFEF4444);
        default:
          return const Color(0xFF475569);
      }
    }

    final borderRadius = BorderRadius.circular(boardSize * 0.1);

    return Container(
      width: fullWidth,
      height: boardSize * 0.06,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isCurrentTurn ? const Color(0xFF334155) : const Color(0xFF1E293B),
        border: Border.all(
          color: isCurrentTurn ? activeBorderColor : const Color(0xFF475569),
          width: 1.0,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (isCurrentTurn && animationController != null)
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: animationController,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: timerBoxColor(),
                      borderRadius: borderRadius,
                    ),
                  ),
                  builder: (context, cachedChild) {
                    return SizedBox(
                      width: fullWidth * (1 - animationController.value),
                      height: boardSize * 0.06,
                      child: cachedChild,
                    );
                  },
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(boardSize * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      username,
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
                          coin.toString(),
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
            ),
          ),
        ],
      ),
    );
  }
}