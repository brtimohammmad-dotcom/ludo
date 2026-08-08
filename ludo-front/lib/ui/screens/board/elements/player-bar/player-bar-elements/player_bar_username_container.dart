import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
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

    final bool isPlayerActive = ref.watch(
      gameControllerProvider.select((s) {
        final players = s?.serverState?.players;
        return (players != null && players.length > playerIndex)
            ? players[playerIndex].playerStatus == PlayerStatus.online
            : false;
      }),
    );

    if (!isPlayerActive) {
      return SizedBox(width: boardSize * 0.29, height: boardSize * 0.06);
    }

    final totalPlayers = ref.watch(
      gameControllerProvider.select(
            (s) => s?.serverState?.numberOfPlayers ?? 2,
      ),
    );
    final playerColor = recognitionPlayerColor(playerIndex, totalPlayers);
    final bool isAvatarOnLeft =
        playerColor == PlayerColor.red || playerColor == PlayerColor.blue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAvatarOnLeft) ...[
          _PlayerAvatar(
            playerIndex: playerIndex,
            boardSize: boardSize,
            playerColor: playerColor,
          ),
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
          _PlayerAvatar(
            playerIndex: playerIndex,
            boardSize: boardSize,
            playerColor: playerColor,
          ),
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
      gameControllerProvider.select(
            (s) =>
        s?.serverState?.currentTurn == playerColor &&
            s?.serverState?.gameStatus == GameStatus.start,
      ),
    );

    final activeBorderColor = switch (playerColor) {
      PlayerColor.red => const Color(0xFFEF4444),
      PlayerColor.green => const Color(0xFF22C55E),
      PlayerColor.yellow => const Color(0xFFFFD700),
      PlayerColor.blue => const Color(0xFF06B6D4),
    };

    return UserAvatar(
      url: avatarUrl,
      size: boardSize * 0.06,
      borderColor: isCurrentTurn
          ? activeBorderColor
          : const Color(0xFF8B5A2B).withValues(alpha: 0.5),
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

    final (gameStatus, totalPlayers, isCurrentTurn) = ref.watch(
      gameControllerProvider.select((s) {
        final gStatus = s?.serverState?.gameStatus;
        final totalP = s?.serverState?.numberOfPlayers ?? 2;
        final myTurn = s?.serverState?.currentTurn == playerColor;
        final tStatus = myTurn ? s?.serverState?.turnStatus : null;

        final currentTurn =
            myTurn &&
                gStatus == GameStatus.start &&
                tStatus != TurnStatus.waitingForAnimate;

        return (gStatus, totalP, currentTurn);
      }),
    );

    final borderRadius = BorderRadius.circular(boardSize * 0.1);
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';

    return Container(
      width: fullWidth,
      height: boardSize * 0.06,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: isCurrentTurn
              ? const [Color(0xFF5A351E), Color(0xFF3B2012)]
              : const [Color(0xFF2A160C), Color(0xFF1E0E07)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: isCurrentTurn
              ? const Color(0xFFFFD700)
              : const Color(0xFF8B5A2B).withValues(alpha: 0.4),
          width: isCurrentTurn ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isCurrentTurn)
            const BoxShadow(
              color: Color(0x66FFD700),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            if (isCurrentTurn && gameStatus == GameStatus.start)
              _TimerProgressBar(absences: absences!),

            Directionality(
              textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
              child: Center(
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
                      _CoinBadge(boardSize: boardSize, coin: coin),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ⚡ ویجت اختصاصی نوار تایمر
// -----------------------------------------------------------------------------
class _TimerProgressBar extends ConsumerWidget {
  const _TimerProgressBar({required this.absences});

  final int absences;

  Color _getTimerColor() {
    switch (absences) {
      case 1:
        return const Color(0xFFD97706); // نارنجی چوبی
      case 2:
        return const Color(0xFFDC2626); // قرمز هشداری
      default:
        return const Color(0xFFB45309); // طلایی قهوه‌ای گرم
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref
        .read(gameControllerProvider.notifier)
        .animationController;

    if (controller == null) return const SizedBox.shrink();

    final timerColor = _getTimerColor();

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (1.0 - controller.value).clamp(0.0, 1.0),
              heightFactor: 1.0,
              child: ColoredBox(
                color: timerColor.withValues(alpha: 0.6),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ⚡ ویجت کوچک نمایش سکه
// -----------------------------------------------------------------------------
class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.boardSize, required this.coin});

  final double boardSize;
  final int coin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: boardSize * 0.01,
        vertical: boardSize * 0.005,
      ),
      decoration: BoxDecoration(
        color: const Color(0x66000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: const Color(0xFFFFD700),
            size: boardSize * 0.02,
          ),
          SizedBox(width: boardSize * 0.005),
          Text(
            context.num(coin),
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontSize: boardSize * 0.02,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}