import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/ui/alerts/alert_background.dart';
import 'package:ludo/ui/alerts/reconnecting_alert.dart';

import 'package:ludo/ui/elements/board/main_board.dart';
import 'package:ludo/ui/alerts/winner_alert.dart';

import 'package:ludo/ui/mappers/player_bar_mapper.dart';

class Board extends StatefulWidget {
  final GameController gameController;

  const Board({super.key, required this.gameController});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    // ست کردن کالبک
    widget.gameController.onGameFinished = () {
      if (mounted &&
          widget.gameController.gameState!.serverState.winner != null) {
        _showDialog(AlertBackground(alert: WinnerAlert(
            winner: widget.gameController.gameState!.serverState.winner!,
            gameController: widget.gameController)));
      }
    };
    widget.gameController.gameRepository.dataSource
        .onPlayerReconnectingAttemptCallback =
        (int attemptNumber) {
      _showDialog(AlertBackground(alert: ReconnectingAlert()));
    };
    widget.gameController.animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    );
    widget.gameController.animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // وقتی به صفر رسید، دوباره شروع کن
        widget.gameController.animationController!.reset();
        widget.gameController.animationController!.forward();
      }
    });
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog,
    );
  }

  @override
  void dispose() {
    debugPrint("🧹 Board dispose called");
    widget.gameController.dispose(); // ✅ این خیلی مهم است
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return ListenableBuilder(
      listenable: widget.gameController,
      builder: ((context, child) {
        return widget.gameController.gameState == null
            ? Center(
          child: Lottie.asset(
              "assets/lotties/Happy girl.json",
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              frameRate: FrameRate(30),

              renderCache: RenderCache.raster
          ),
        )
            : Center(
          // مرکزی کردن کل محتوا
          child: LayoutBuilder(
            builder: (context, constraints) {
              int gameMode =
                  widget.gameController.gameState!.serverState.gameMode;

              final maxAvailableWidth = screenWidth;
              final maxAvailableHeight = screenHeight;

              final boardSize = (maxAvailableWidth < maxAvailableHeight
                  ? maxAvailableWidth
                  : maxAvailableHeight * 0.86);

              final barHeight = boardSize * 0.08;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // جمع شدن دور محتوا
                children: [
                  PlayerBar(
                    boardSize: boardSize,
                    barHeight: barHeight,
                    gameController: widget.gameController,
                    leftPlayerIndex: gameMode == 2 ? -1 : 1,
                    rightPlayerIndex: gameMode == 2 ? 1 : 2,
                  ),
                  MainBoard(
                    boardSize: boardSize,
                    gameController: widget.gameController,
                  ),
                  PlayerBar(
                    boardSize: boardSize,
                    barHeight: barHeight,
                    gameController: widget.gameController,
                    leftPlayerIndex: 0,
                    rightPlayerIndex: gameMode == 2 ? -1 : 3,
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
