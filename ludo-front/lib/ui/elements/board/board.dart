import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/ui/elements/board/main_board.dart';
import 'package:ludo/ui/mappers/player-bar-mapper/player_bar.dart';

import 'board_ui_event_handler.dart';

class Board extends ConsumerStatefulWidget {
  const Board({super.key});

  @override
  ConsumerState<Board> createState() => _BoardState();
}

class _BoardState extends ConsumerState<Board>
    with SingleTickerProviderStateMixin {
  late BoardUiEventHandler _uiEventHandler;

  @override
  void initState() {
    super.initState();
    final gameController = ref.read(gameControllerProvider.notifier);
    // مقداردهی و ثبت کالبک‌ها از طریق هندلر اختصاصی UI
    _uiEventHandler = BoardUiEventHandler(
      context: context,
      gameController: gameController,

    );
    _uiEventHandler.init();
    _uiEventHandler.checkAndShowWaitingDialog();

    // انیمیشن کنترلر محلی بورد
    gameController.animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              gameController.animationController!.reset();
              gameController.animationController!.forward();
            }
          });
  }

  @override
  void dispose() {
    debugPrint("🧹 Board dispose called");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    final gameMode = ref.watch(
      gameControllerProvider.select(
        (state) => state?.serverState?.numberOfPlayers ?? 2,
      ),
    );
    ref.listen<GameStatus?>(
      gameControllerProvider.select((state) => state?.serverState?.gameStatus),
      (previous, next) {
        debugPrint("🔄 [UI Event] Game Status Changed: $next");

        // اگر وضعیت تغییر کرد و دیگر منتظر بازیکن نبودیم، آلرت را ببند
        if (next != GameStatus.waitingForPlayer) {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
      },
    );
    final barHeight = boardSize * 0.08;

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerBar(
              boardSize: boardSize,
              barHeight: barHeight,
              leftPlayerIndex: gameMode == 2 ? -1 : 1,
              rightPlayerIndex: gameMode == 2 ? 1 : 2,
            ),
            MainBoard( boardSize: boardSize),
            PlayerBar(
              boardSize: boardSize,
              barHeight: barHeight,
              leftPlayerIndex: 0,
              rightPlayerIndex: gameMode == 2 ? -1 : 3,
            ),
          ],
        ),
      ),
    );
  }
}
