import 'package:flutter/material.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/utils/alerts/exit_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class PlayerBar extends StatelessWidget {
  const PlayerBar({
    super.key,
    required this.boardSize,
    required this.barHeight,
    required this.gameController,
    required this.leftPlayerIndex,
    required this.rightPlayerIndex,
  });

  final int leftPlayerIndex;
  final int rightPlayerIndex;
  final double boardSize;
  final double barHeight;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boardSize, // عرض برابر با برد
      height: barHeight,
      color: Colors.blueGrey,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: boardSize * 0.037),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PlayerBarUsernameContainer(
              boardSize: boardSize,
              gameController: gameController,
              playerIndex: leftPlayerIndex,
              barHeight: barHeight,
            ),
            if (leftPlayerIndex == 1 || leftPlayerIndex == -1)
              ExitIcon(gameController: gameController, boardSize: boardSize),
            if (leftPlayerIndex == 0)
              RollButton(gameController: gameController, boardSize: boardSize),

            PlayerBarUsernameContainer(
              boardSize: boardSize,
              gameController: gameController,
              playerIndex: rightPlayerIndex,
              barHeight: barHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class RollButton extends StatelessWidget {
  const RollButton({
    required this.gameController,
    super.key,
    required this.boardSize,
  });

  final double boardSize;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    bool myTurnToRoll = gameController.isMyTurnToRoll();
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: boardSize * 0.01),
      child: Container(
        decoration: BoxDecoration(
          gradient: myTurnToRoll
              ? LinearGradient(
                  colors: [
                    Colors.lightGreenAccent,
                    Colors.lightGreenAccent.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(colors: [Colors.white30, Colors.white38]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsetsGeometry.symmetric(horizontal: boardSize * 0.02),

            backgroundColor: Colors.transparent,
            // شفاف
            foregroundColor: myTurnToRoll ? Colors.white : Colors.white54,
            elevation: myTurnToRoll ? 4 : 0,
            shadowColor: Colors.green.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            gameController.rollDice();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: boardSize * 0.03,
              vertical: boardSize * 0.01,
            ),
            child: Text('roll', style: TextStyle(fontSize: boardSize * 0.03)),
          ),
        ),
      ),
    );
  }
}

class ExitIcon extends StatelessWidget {
  const ExitIcon({
    super.key,
    required this.boardSize,
    required this.gameController,
  });

  final GameController gameController;

  final double boardSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //     lastGameController.gameRepository.demoDisconnectAndConnect();
        //   },
        //   child: Text("conn-dis"),
        // ),
        GestureDetector(
          onTap: () {
            showAnimatedDialog(
              context: context,
              child: ExitButtonAlert(gameController: gameController),
            );
          },
          child: Icon(
            Icons.exit_to_app_rounded,
            color: Colors.black38,
            size: boardSize * 0.06,
          ),
        ),
      ],
    );
  }
}

class PlayerBarUsernameContainer extends StatelessWidget {
  const PlayerBarUsernameContainer({
    super.key,
    required this.boardSize,
    required this.gameController,
    required this.playerIndex,
    required this.barHeight,
  });

  final double boardSize;
  final GameController gameController;
  final int playerIndex;
  final double barHeight;

  @override
  Widget build(BuildContext context) {
    ServerState state = gameController.gameState!.serverState!;
    PlayerColor playerColor = recognitionPlayerColor(
      playerIndex,
      state.numberOfPlayers,
    );
    Text usernameStatusPicker() {
      if (state.players.length < playerIndex + 1) {
        return Text(
          "waiting for player",
          style: TextStyle(
            color: Colors.black45.withAlpha(30),
            decoration: TextDecoration.none,
            fontSize: barHeight * 0.36,
          ),
        );
      } else {
        if (state.players[playerIndex].playerStatus == PlayerStatus.online) {
          return Text(
            state.players[playerIndex].username,
            style: TextStyle(
              color: playerUserNameBoxColor(
                gameController,
                playerIndex,
                state.numberOfPlayers,
              ),
              decoration: TextDecoration.none,
              fontSize: barHeight * 0.4,
              shadows: [
                state.currentTurn ==
                        recognitionPlayerColor(playerIndex, state.numberOfPlayers)
                    ? BoxShadow(
                        color: Colors.black54,
                        offset: Offset(-0.5, 0.5),
                        blurRadius: 0.2,
                      )
                    : BoxShadow(color: Colors.transparent),
              ],
            ),
          );
        } else {
          return Text(
            "out",
            style: TextStyle(
              color: Colors.black45.withAlpha(30),
              decoration: TextDecoration.none,
              fontSize: barHeight * 0.36,
            ),
          );
        }
      }
    }

    Color usernameTimerBoxColor() {
      if (state.gameStatus != GameStatus.start) {
        if (state.players.length <= playerIndex) {
          return Colors.transparent;
        } else {
          return Colors.white;
        }
      } else {
        switch (state.players[playerIndex].numberOfAbsences) {
          case (0):
            return Colors.white;
          case (1):
            return Colors.yellow.shade200;
          case (2):
            return Colors.red.shade200;
          case (3):
            return Colors.transparent;
          default:
            return Colors.transparent;
        }
      }
    }

    final bool isCurrentTurn =
        playerColor == state.currentTurn &&
        state.gameStatus == GameStatus.start &&
        state.turnStatus != TurnStatus.waitingForAnimate;
    if (isCurrentTurn) {
      gameController.animationController!.forward();
    }
    final double fullWidth = boardSize * 0.29;

    return playerIndex == -1
        ? SizedBox(width: boardSize * 0.29, height: boardSize * 0.06)
        : Container(
            width: boardSize * 0.29,
            height: boardSize * 0.06,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(boardSize * 0.1),
              color: Colors.blueGrey,
              border: Border.all(
                color: playerUserNameBoxColor(
                  gameController,
                  playerIndex,
                  state.numberOfPlayers,
                ),
                width: boardSize * 0.004,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black38, offset: Offset(-1, 3)),
              ],
            ),
            child: Stack(
              children: [
                // کانتینر سفید که کوچک می‌شود (لایه پشتی)
                Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: gameController.animationController!,
                    builder: (context, child) {
                      final double targetWidth = isCurrentTurn
                          ? fullWidth *
                                (1 - gameController.animationController!.value)
                          : fullWidth;

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
                // متن (لایه رویی)
                Center(child: usernameStatusPicker()),
              ],
            ),
          );
  }
}

PlayerColor recognitionPlayerColor(int playerIndex, int gameMode) {
  switch (playerIndex) {
    case (0):
      return PlayerColor.red;
    case (1):
      return gameMode == 2 ? PlayerColor.yellow : PlayerColor.blue;

    case (2):
      return PlayerColor.yellow;

    case (3):
      return PlayerColor.green;

    default:
      return PlayerColor.red;
  }
}

Color playerUserNameBoxColor(
  GameController gameController,
  int playerIndex,
  int gameMode,
) {
  PlayerColor currentPlayerColor = recognitionPlayerColor(
    playerIndex,
    gameMode,
  );

  if (currentPlayerColor ==
      gameController.gameState!.serverState!.currentTurn) {
    switch (playerIndex) {
      case (0):
        return Colors.red.shade900;
      case (1):
        return gameMode == 2 ? Colors.yellow.shade700 : Colors.blue.shade300;

      case (2):
        return Colors.yellow.shade700;

      case (3):
        return Colors.green.shade400;

      default:
        return Colors.red;
    }
  } else {
    return Colors.black45;
  }
}
