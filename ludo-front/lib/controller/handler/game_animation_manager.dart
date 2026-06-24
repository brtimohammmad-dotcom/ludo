import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

class GameAnimationManager {
  final GameController controller;

  GameAnimationManager(this.controller);

  Future<void> moveTokenStepByStep(ServerState newState) async {
    if (controller.currentGameState?.serverState == null) return;

    final newLivePlayer = newState.players.firstWhere(
      (p) => p.userId == controller.currentGameState!.livePlayer!.userId,
      orElse: () => controller.currentGameState!.livePlayer!,
    );

    int? movedTokenIndex;
    int? targetPathIndex;

    for (
      int i = 0;
      i < controller.currentGameState!.serverState!.tokens.length;
      i++
    ) {
      final oldToken = controller.currentGameState!.serverState!.tokens[i];
      final newToken = newState.tokens.firstWhere((t) => t.id == oldToken.id);

      if (newToken.pathIndex != oldToken.pathIndex &&
          newToken.playerColor ==
              controller.currentGameState!.serverState!.currentTurn) {
        movedTokenIndex = i;
        targetPathIndex = newToken.pathIndex;
        break;
      }
    }

    if (movedTokenIndex == null || targetPathIndex == null) {
      controller.updateState(
        GameState(serverState: newState, livePlayer: newLivePlayer),
      );
      return;
    }

    final oldPathIndex = controller
        .currentGameState!
        .serverState!
        .tokens[movedTokenIndex]
        .pathIndex;

    for (int step = oldPathIndex; step < targetPathIndex; step++) {
      if (controller.currentGameState?.serverState == null) {
        return;
      }

      final currentToken =
          controller.currentGameState!.serverState!.tokens[movedTokenIndex];
      final updatedToken = currentToken.copyWith(pathIndex: step + 1);
      final updatedTokens = List<Token>.from(
        controller.currentGameState!.serverState!.tokens,
      );
      updatedTokens[movedTokenIndex] = updatedToken;

      controller.updateState(
        controller.currentGameState!.copyWith(
          serverState: controller.currentGameState!.serverState!.copyWith(
            turnStatus: TurnStatus.waitingForAnimate,
            tokens: updatedTokens,
          ),
          livePlayer: newLivePlayer,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      controller.playSfx("assets/audio/sound-effect/move_token.wav");
    }
  }

  Future<void> moveTokenStepByStepLocally(String tokenId, int steps) async {
    if (controller.currentGameState?.serverState == null ||
        controller.isMovingToken) {
      return;
    }
    controller.isMovingToken = true;

    try {
      controller.animationController?.stop();

      int movedTokenIndex = controller.currentGameState!.serverState!.tokens
          .indexWhere((t) => t.id == tokenId);

      if (movedTokenIndex == -1) return;

      final currentToken =
          controller.currentGameState!.serverState!.tokens[movedTokenIndex];
      final oldPathIndex = currentToken.pathIndex;

      // 🟢 حالت خاص: مهره داخل Base است (1-) و تاس 6 آمده است
      if (oldPathIndex == -1 && steps == 6) {
        final updatedToken = currentToken.copyWith(pathIndex: 0);
        final updatedTokens = List<Token>.from(
          controller.currentGameState!.serverState!.tokens,
        );
        updatedTokens[movedTokenIndex] = updatedToken;

        controller.updateState(
          controller.currentGameState!.copyWith(
            serverState: controller.currentGameState!.serverState!.copyWith(
              turnStatus: TurnStatus.waitingForAnimate,
              tokens: updatedTokens,
            ),
          ),
        );

        // یک تاخیر کوتاه برای حس شدن حرکت ورود به زمین
        await Future.delayed(const Duration(milliseconds: 300));
        controller.playSfx("assets/audio/sound-effect/move_token.wav");

        controller.animationController?.reset();
        controller.animationController?.forward();
        return; // خروج از متد چون حرکت تمام شده است
      }

      // 🔴 حالت عادی: مهره در زمین است و باید پله‌پله جلو برود
      // اگر مهره در بیس باشد و تاس ۶ نباشد، اصلاً نباید حرکت کند
      if (oldPathIndex == -1) return;

      final targetPathIndex = oldPathIndex + steps;

      for (int step = oldPathIndex; step < targetPathIndex; step++) {
        if (controller.currentGameState?.serverState == null) return;

        final tokenAtStep =
            controller.currentGameState!.serverState!.tokens[movedTokenIndex];
        final updatedToken = tokenAtStep.copyWith(pathIndex: step + 1);
        final updatedTokens = List<Token>.from(
          controller.currentGameState!.serverState!.tokens,
        );
        updatedTokens[movedTokenIndex] = updatedToken;

        controller.updateState(
          controller.currentGameState!.copyWith(
            serverState: controller.currentGameState!.serverState!.copyWith(
              turnStatus: TurnStatus.waitingForAnimate,
              tokens: updatedTokens,
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));
        controller.playSfx("assets/audio/sound-effect/move_token.wav");
      }

      controller.animationController?.reset();
      controller.animationController?.forward();
    } finally {
      controller.isMovingToken = false;
    }
  }

  Future<void> animateDiceRoll(ServerState newState) async {
    if (controller.currentGameState?.livePlayer == null) return;

    final newLivePlayer = newState.players.firstWhere(
      (p) => p.userId == controller.currentGameState!.livePlayer!.userId,
      orElse: () => controller.currentGameState!.livePlayer!,
    );

    controller.animationController?.stop();
    controller.playSfx("assets/audio/sound-effect/dice_rolling.wav");

    controller.updateState(
      GameState(
        serverState: controller.currentGameState!.serverState!.copyWith(
          turnStatus: TurnStatus.rollDiceRequestInFlight,
        ),
        livePlayer: newLivePlayer,
        gameStage: GameStage.boardStage,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 250));

    final tokenIsActive = newState.tokens.any((token) {
      final newGameState = GameState(
        serverState: newState,
        livePlayer: controller.currentGameState!.livePlayer,
        gameStage: GameStage.boardStage,
      );
      return TokenRules.canActiveToken(token, newGameState);
    });

    if (tokenIsActive) {
      controller.updateState(
        GameState(
          serverState: newState,
          livePlayer: newLivePlayer,
          gameStage: GameStage.boardStage,
        ),
      );
    } else {
      controller.updateState(
        GameState(
          serverState: controller.currentGameState!.serverState!.copyWith(
            lastDiceValue: newState.lastDiceValue,
            turnStatus: TurnStatus.waitingForAnimate,
          ),
          livePlayer: newLivePlayer,
          gameStage: GameStage.boardStage,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 750));

      controller.updateState(
        GameState(
          serverState: newState,
          livePlayer: newLivePlayer,
          gameStage: GameStage.boardStage,
        ),
      );
    }
    controller.animationController?.reset();
    controller.animationController?.forward();
  }
}
