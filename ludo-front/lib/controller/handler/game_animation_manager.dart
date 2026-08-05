import 'package:flutter/widgets.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/domain/rules/token_rules.dart';

class GameAnimationManager {
  final GameController controller;

  GameAnimationManager(this.controller);

  /// پخش ریتمیک افکت صوتی حرکت مهره به تعداد گام‌ها
  Future<void> _playStepSounds(int stepCount) async {
    if (stepCount <= 0) return;

    // زمان‌بندی هر قدم هماهنگ با سرعت انیمیشن (100 میلی‌ثانیه برای هر خانه)
    const int stepDurationMs = 100;

    for (int i = 0; i < stepCount; i++) {
      controller.playSfx("assets/audio/sound-effect/move_token.wav");
      await Future.delayed(const Duration(milliseconds: stepDurationMs));
    }
  }

  /// اجرای امن انیمیشن پس از اتمام رندر فریم جاری برای جلوگیری از لگ و Drop Frame
  void _safeStartAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.animationController != null) {
        if (controller.animationController!.isAnimating) {
          controller.animationController!.stop();
        }
        controller.animationController!.reset();
        controller.animationController!.forward();
      }
    });
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

    final isFromBase = oldPosition == -1;
    final stepCount = isFromBase ? 1 : (targetPosition - oldPosition).clamp(1, 6);

    // 🔊 پخش صدا بعد از اتمام رندر فریم اول (آغاز انیمیشن visual)
    if (!isFromBase) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playStepSounds(stepCount);
      });
    }

    // ⚡ زمان‌بندی کل انیمیشن (200ms پایه + stepCount * 100ms)
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

      // 🔊 پخش ریتمیک صدا
      if (!isFromBase) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _playStepSounds(stepCount);
        });
      }

      await Future.delayed(Duration(milliseconds: 200 + stepCount * 100));

      // ⚡ استارت انیمیشن بعدی پس از اتمام رندر فریم
      _safeStartAnimation();
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

    // ⚡ شروع انیمیشن تاس بدون افت فریم
    _safeStartAnimation();
  }
}