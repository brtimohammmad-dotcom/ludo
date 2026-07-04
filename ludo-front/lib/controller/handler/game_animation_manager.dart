import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

class GameAnimationManager {
  final GameController controller;

  GameAnimationManager(this.controller);

  Future<void> moveTokenStepByStep({
    required int tokenId,
    required int targetPosition,
    required bool hasKick,
    int? kickedTokenId,
  }) async {
    if (controller.currentGameState?.serverState == null) return;

    final serverState = controller.currentGameState!.serverState!;

    // ۱. پیدا کردن ایندکس توکن حرکت‌کرده در استیت فعلی فرانت‌اند
    final movedTokenIndex = serverState.tokens.indexWhere(
      (t) => t.id == tokenId.toString(),
    );
    if (movedTokenIndex == -1) return;

    final oldToken = serverState.tokens[movedTokenIndex];

    // پوزیشن فعلی توکن در فرانت‌اَند قبل از حرکت
    final oldPosition = oldToken
        .pathIndex; // یا هر فیلدی که نام پوزیشن شماست (مثلاً position یا pathIndex)

    // ۲. اجرای انیمیشن پله‌پله به سمت جلو
    for (int step = oldPosition; step < targetPosition; step++) {
      if (controller.currentGameState?.serverState == null) return;

      // آپدیت کردن پوزیشن توکن یک قدم به جلو
      final updatedToken = controller
          .currentGameState!
          .serverState!
          .tokens[movedTokenIndex]
          .copyWith(pathIndex: step + 1);

      final updatedTokens = List<Token>.from(
        controller.currentGameState!.serverState!.tokens,
      );
      updatedTokens[movedTokenIndex] = updatedToken;

      // اعمال استیت جدید برای رندر شدن تک‌قدم توکن
      controller.updateState(
        controller.currentGameState!.copyWith(
          serverState: controller.currentGameState!.serverState!.copyWith(
            turnStatus: TurnStatus.waitingForAnimate,
            tokens: updatedTokens,
          ),
        ),
      );

      // صدا و تاخیر برای حس حرکت مهره
      controller.playSfx("assets/audio/sound-effect/move_token.wav");
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // ۳. مدیریت انیمیشن کیک (Kicked) یا زدن مهره حریف
    if (hasKick && kickedTokenId != null) {
      final kickedTokenIndex = controller.currentGameState!.serverState!.tokens
          .indexWhere((t) => t.id == kickedTokenId.toString());

      if (kickedTokenIndex != -1) {
        // پخش افکت صدای زدن مهره
        controller.playSfx("assets/audio/sound-effect/kick_token.wav");

        final updatedTokens = List<Token>.from(
          controller.currentGameState!.serverState!.tokens,
        );
        // برگرداندن مهره خورده شده به خانه ابتدا (پوزیشن ۱-)
        updatedTokens[kickedTokenIndex] = updatedTokens[kickedTokenIndex]
            .copyWith(pathIndex: -1);

        controller.updateState(
          controller.currentGameState!.copyWith(
            serverState: controller.currentGameState!.serverState!.copyWith(
              tokens: updatedTokens,
            ),
          ),
        );
      }
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
          lastDiceValue: newState.lastDiceValue,
        ),
        livePlayer: newLivePlayer,
        gameStage: GameStage.boardStage,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 250));
    final currentGameState = GameState(
      serverState: newState,
      livePlayer: newLivePlayer,
      gameStage: GameStage.boardStage,
    );
    final tokenIsActive = newState.tokens.any((token) {
      return TokenRules.canActiveToken(token, currentGameState);
    });

    if (tokenIsActive) {
      controller.updateState(currentGameState);
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
      controller.updateState(currentGameState);
    }
    controller.animationController?.reset();
    controller.animationController?.forward();
  }
}
