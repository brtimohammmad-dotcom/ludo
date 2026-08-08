import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/screens/board/elements/player-bar/player_bar.dart';
import 'package:ludo/ui/screens/board/main_board.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/winner_alert.dart';
import 'package:ludo/ui/utils/painter.dart';
import 'board_ui_event_handler.dart';

class Board extends ConsumerStatefulWidget {
  const Board({super.key});

  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board> with SingleTickerProviderStateMixin {
  late BoardUiEventHandler _uiEventHandler;
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    final gameController = ref.read(gameControllerProvider.notifier);
    _uiEventHandler = BoardUiEventHandler(
      context: context,
      gameController: gameController,
    );
    _uiEventHandler.checkAndShowWaitingDialog();


    gameController.animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    _gameController = ref.read(gameControllerProvider.notifier);
  }

  @override
  void dispose() {
    debugPrint("🧹 Board dispose called");
    _gameController.animationController?.dispose();
    _gameController.animationController = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight ? screenWidth : screenHeight * 0.86);

    final numberOfPlayers = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.numberOfPlayers ?? 2),
    );

    ref.listen<GameStatus?>(
      gameControllerProvider.select((state) => state?.serverState?.gameStatus),
          (previous, next) {
        if (previous == GameStatus.waitingForPlayer && next == GameStatus.start) {
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        } else if (next == GameStatus.finished) {
          if (!context.mounted) return;
          final winner = _gameController.currentGameState?.serverState?.winner;
          if (winner != null) {
            showAnimatedDialog(
              context: context,
              barrierDismissible: false,
              child: WinnerAlert(winner: winner, gameController: _gameController),
            );
          }
        } else if (next == GameStatus.exit) {
          _gameController.resetGame();
          _gameController.updateState(
            _gameController.currentGameState?.copyWith(gameStage: GameStage.joinStage),
          );
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      },
    );
    final barHeight = boardSize * 0.1;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0F0A), // تم چوبی تیره و لوکس
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: LudoBackgroundPainter(),
              ),
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A160C), // قهوه‌ای سوخته چوبی ملایم
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF8B5A2B), // حاشیه طلایی-قهوه‌ای چوبی
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        child: PlayerBar(
                          boardSize: boardSize,
                          barHeight: barHeight,
                          leftPlayerIndex: numberOfPlayers == 2 ? -1 : 1,
                          rightPlayerIndex: numberOfPlayers == 2 ? 1 : 2,
                        ),
                      ),
                      RepaintBoundary(child: MainBoard(boardSize: boardSize)),
                      RepaintBoundary(
                        child: PlayerBar(
                          boardSize: boardSize,
                          barHeight: barHeight,
                          leftPlayerIndex: 0,
                          rightPlayerIndex: numberOfPlayers == 2 ? -1 : 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}