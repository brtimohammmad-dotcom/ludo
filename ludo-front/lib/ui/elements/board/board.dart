import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/alerts/alert_background.dart';
import 'package:ludo/ui/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/elements/board/main_board.dart';
import 'package:ludo/ui/alerts/winner_alert.dart';
import 'package:ludo/ui/join_screen.dart';
import 'package:ludo/ui/mappers/player_bar_mapper.dart';

class Board extends StatefulWidget {
  final GameController gameController;

  const Board({super.key, required this.gameController});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with SingleTickerProviderStateMixin {
  late Future<LottieComposition> diceComposition;

  @override
  void initState() {
    super.initState();

    // --- GAME FINISHED ---
    widget.gameController.onGameFinished = () {
      if (!mounted) return;

      final winner = widget.gameController.gameState?.serverState?.winner;
      if (winner != null) {
        _showDialog(
          AlertBackground(alert: WinnerAlert(winner: winner)),
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
          MaterialPageRoute(builder: (_) => const JoinScreen()),
              (route) => false,
        );
      }
    };

    // --- RECONNECTION FAILED ---
    widget.gameController.onReconnectionFailed = () {
      if (!mounted) return;

      _showDialog(
        AlertBackground(
          alert: ReconnectingFailedAlert(
            onHomePressed: () async {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }

              widget.gameController.deleteGameState();

              await Future.delayed(const Duration(milliseconds: 50));

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const JoinScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ),
      );
    };

    // --- ANIMATION CONTROLLER ---
    widget.gameController.animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.gameController.animationController!.reset();
        widget.gameController.animationController!.forward();
      }
    });

    diceComposition = AssetLottie("assets/lotties/Dice Rolling.json").load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (int i = 1; i <= 6; i++) {
      precacheImage(AssetImage('assets/images/dice/$i.png'), context);
    }
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => dialog,
    );
  }

  @override
  void dispose() {
    debugPrint("🧹 Board dispose called");

    if (!widget.gameController.isDisposed) {
      widget.gameController.resetGame();
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

        if (state == null) {
          return const Center(child: CupertinoActivityIndicator());
        }

        final gameMode = state.gameMode;

        final boardSize = (screenWidth < screenHeight
            ? screenWidth
            : screenHeight * 0.86);

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
