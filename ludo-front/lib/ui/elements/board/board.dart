import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/utils/alerts/game_status_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/elements/board/main_board.dart';
import 'package:ludo/ui/utils/alerts/winner_alert.dart';
import 'package:ludo/ui/join_screen.dart';
import 'package:ludo/ui/mappers/player_bar_mapper.dart';
import 'package:ludo/ui/utils/animated_route.dart';

class Board extends StatefulWidget {
  final GameController gameController;

  const Board({super.key, required this.gameController});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  late Future<LottieComposition> diceComposition;
  bool _isWaitingDialogShown = false; // ⬅️ اضافه شد

  @override
  void initState() {
    super.initState();
    widget.gameController.isInBoard = true;
    // --- GAME FINISHED ---
    widget.gameController.onGameFinished = () {
      if (!mounted) return;

      final winner = widget.gameController.gameState?.serverState?.winner;
      if (winner != null) {
        showAnimatedDialog(
          context: context,
          child: WinnerAlert(
            winner: winner,
            gameController: widget.gameController,
          ),
        );
      }
    };

    // --- PLAYER EXIT ---
    widget.gameController.onPlayerExit = () async {
      debugPrint('...player exited...');

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      widget.gameController.deleteGameState();

      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          animatedRoute(
            page: JoinScreen(),
            duration: Duration(seconds: 1),
            type: RouteAnimation.fade,
          ),
          (route) => false,
        );
      }
    };
    widget.gameController.onGameStarted = () {
      if (_isWaitingDialogShown) {
        Navigator.of(context).pop();
        _isWaitingDialogShown = false;
      }
    };
    // --- RECONNECTION FAILED ---
    widget.gameController.onReconnectionFailed = () {
      if (!mounted) return;
      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            widget.gameController.deleteGameState();

            await Future.delayed(const Duration(milliseconds: 50));

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                animatedRoute(
                  page: JoinScreen(),
                  duration: Duration(seconds: 1),
                  type: RouteAnimation.fade,
                ),
                (route) => false,
              );
            }
          },
          textButton: "Home",
        ),
      );
    };

    // --- ANIMATION CONTROLLER ---
    widget.gameController.animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.gameController.animationController!.reset();
              widget.gameController.animationController!.forward();
            }
          });

    diceComposition = AssetLottie("assets/lotties/Dice Rolling.json").load();
  }

  @override
  void dispose() {
    debugPrint("🧹 Board dispose called");
    widget.gameController.isInBoard = false;
    if (!widget.gameController.isDisposed) {
      widget.gameController.deleteGameState();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, child) {
        final state = widget.gameController.gameState?.serverState;
        final boardSize = (screenWidth < screenHeight
            ? screenWidth
            : screenHeight * 0.86);
        if (state == null) {
          return Center(
            child: LoadingAnimationWidget.fourRotatingDots(
              color: Colors.lightGreenAccent,
              size: boardSize * 0.2,
            ),
          );
        }

        if (state.gameStatus == GameStatus.waitingForPlayer &&
            !_isWaitingDialogShown) {
          _isWaitingDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            showAnimatedDialog(
              context: context,
              barrierDismissible: false,
              child: WaitingForPlayersAlert(
                gameController: widget.gameController,
                onExit: () {
                  widget.gameController.exitGame();
                },
              ),
            );
          });
        }
        final gameMode = state.numberOfPlayers;

        final barHeight = boardSize * 0.08;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerBar(
                boardSize: boardSize,
                barHeight: barHeight,
                gameController: widget.gameController,
                leftPlayerIndex: gameMode == 2 ? -1 : 1,
                rightPlayerIndex: gameMode == 2 ? 1 : 2,
              ),
              MainBoard(
                diceComposition: diceComposition,
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
          ),
        );
      },
    );
  }
}
