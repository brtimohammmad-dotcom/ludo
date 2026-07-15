import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'start_game_button.dart';

class GameSelectionButtons extends ConsumerWidget {
  final double boardSize;
  final dynamic handler; // JoinScreenHandler

  const GameSelectionButtons({
    super.key,
    required this.boardSize,
    required this.handler,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levels = GameLevel.values
        .where((level) => level != GameLevel.free)
        .toList();
    return Container(
      constraints: BoxConstraints(maxHeight: boardSize * 0.65),
      // مدیریت فضا در صفحه
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: levels.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: boardSize * 0.02),
        itemBuilder: (context, index) {
          // درون متد itemBuilder در کلاس GameSelectionButtons:
          final level = levels[index];

          final isFourPlayerDisabled = (level == GameLevel.gold || level == GameLevel.vip);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // نام لول (مثلا Gold Table)
              Text(
                "${level.displayName} Table",
                style: TextStyle(
                  color: level.color,
                  fontSize: boardSize * 0.035,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              SizedBox(height: boardSize * 0.01),

              if (isFourPlayerDisabled)
                StartGameButton(
                  numberOfPlayers: 2,
                  entryFee: level.entryFee,
                  prizePool: level.prize2P,
                  themeColor: level.color,
                  onPressed: () => handler.handleGameSearch(
                    numberOfPlayers: 2,
                    gameType: GameType.global,
                    gameLevel: level,
                    boardSize: boardSize,
                  ),
                  boardSize: boardSize * 2.03,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // دکمه ۲ نفره
                    StartGameButton(
                      numberOfPlayers: 2,
                      entryFee: level.entryFee,
                      prizePool: level.prize2P,
                      themeColor: level.color,
                      onPressed: () => handler.handleGameSearch(
                        numberOfPlayers: 2,
                        gameType: GameType.global,
                        gameLevel: level,
                        boardSize: boardSize,
                      ),
                      boardSize: boardSize,
                    ),
                    SizedBox(width: boardSize * 0.03),
                    // دکمه ۴ نفره
                    StartGameButton(
                      numberOfPlayers: 4,
                      entryFee: level.entryFee,
                      prizePool: level.prize4P,
                      themeColor: level.color,
                      onPressed: () => handler.handleGameSearch(
                        numberOfPlayers: 4,
                        gameType: GameType.global,
                        gameLevel: level,
                        boardSize: boardSize,
                      ),
                      boardSize: boardSize,
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
