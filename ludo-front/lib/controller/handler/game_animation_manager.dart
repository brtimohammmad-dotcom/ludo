import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

class GameAnimationManager {
  final GameController controller;

  GameAnimationManager(this.controller);

  /// متد کمکی برای پخش صدا به تعداد قدم‌ها با افکت ریتمیک
  Future<void> _playStepSounds(int stepCount) async {
    if (stepCount <= 0) return;

    // زمان هر قدم بر اساس فرمول انیمیشن (100 میلی‌ثانیه برای هر خانه)
    const int stepDurationMs = 100;

    for (int i = 0; i < stepCount; i++) {
      controller.playSfx("assets/audio/sound-effect/move_token.wav");
      await Future.delayed(const Duration(milliseconds: stepDurationMs));
    }
  }

  Future<void> moveTokenStepByStep({
    required int tokenId,
    required int targetPosition,
  }) async {
    if (controller.currentGameState?.serverState == null) return;

    final serverState = controller.currentGameState!.serverState!;

    final movedTokenIndex = serverState.tokens.indexWhere(
          (t) => t.id == tokenId.toString(),
    );
    if (movedTokenIndex == -1) return;

    final oldToken = serverState.tokens[movedTokenIndex];
    final oldPosition = oldToken.pathIndex;

    if (targetPosition <= oldPosition) return;

    final updatedTokens = List<Token>.from(serverState.tokens);
    updatedTokens[movedTokenIndex] =
        oldToken.copyWith(pathIndex: targetPosition);

    controller.updateState(
      controller.currentGameState!.copyWith(
        serverState: serverState.copyWith(
          turnStatus: TurnStatus.waitingForAnimate,
          tokens: updatedTokens,
        ),
      ),
    );

    // محاسبه تعداد خانه‌هایی که مهره باید طی کند
    final isFromBase = oldPosition == -1;
    final stepCount = isFromBase ? 1 : (targetPosition - oldPosition).clamp(1, 6);

    // 🔊 پخش صدا به تعداد stepCount (اگر خروج از بیس نباشد)
    if (!isFromBase) {
      // یک تاخیر کوتاه برای شروع هم‌زمان صدا با آغاز حرکت انیمیشن
      Future.delayed(const Duration(milliseconds: 100), () {
        _playStepSounds(stepCount);
      });
    }

    // ⚡ صبر دقیقاً برابر با زمان اجرای انیمیشن در ویجت (200ms + stepCount * 100ms)
    await Future.delayed(Duration(milliseconds: 200 + stepCount * 100));
  }

  Future<void> moveTokenStepByStepLocally(String tokenId, int steps) async {
    if (controller.currentGameState?.serverState == null ||
        controller.isMovingToken) {
      return;
    }
    controller.isMovingToken = true;

    try {
      controller.animationController?.stop();

      final serverState = controller.currentGameState!.serverState!;
      final movedTokenIndex =
      serverState.tokens.indexWhere((t) => t.id == tokenId);
      if (movedTokenIndex == -1) return;

      final currentToken = serverState.tokens[movedTokenIndex];
      final oldPathIndex = currentToken.pathIndex;

      if (oldPathIndex == -1 && steps != 6) return;

      final newPathIndex = oldPathIndex == -1 ? 0 : oldPathIndex + steps;

      final updatedTokens = List<Token>.from(serverState.tokens);
      updatedTokens[movedTokenIndex] =
          currentToken.copyWith(pathIndex: newPathIndex);

      controller.updateState(
        controller.currentGameState!.copyWith(
          serverState: serverState.copyWith(
            turnStatus: TurnStatus.waitingForAnimate,
            tokens: updatedTokens,
          ),
        ),
      );

      final isFromBase = oldPathIndex == -1;
      final stepCount = isFromBase ? 1 : steps.clamp(1, 6);

      // 🔊 پخش صدا به تعداد stepCount (اگر خروج از بیس نباشد)
      if (!isFromBase) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _playStepSounds(stepCount);
        });
      }

      // ⚡ هماهنگ با زمان انیمیشن
      await Future.delayed(Duration(milliseconds: 200 + stepCount * 100));

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

      await Future.delayed(const Duration(milliseconds: 600));
      controller.updateState(currentGameState);
    }
    controller.animationController?.reset();
    controller.animationController?.forward();
  }
}