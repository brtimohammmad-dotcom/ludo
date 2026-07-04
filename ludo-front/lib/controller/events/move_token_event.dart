import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

class MoveTokenEvent implements GameEvent {
  final int tokenId;
  final int targetPosition;
  final bool hasKick;
  final int? kickedTokenId;
  final String? turnStatus;
  final String? currentTurn;

  const MoveTokenEvent({
    required this.tokenId,
    required this.targetPosition,
    required this.hasKick,
    this.turnStatus,
    this.currentTurn,
    this.kickedTokenId,
  });

  factory MoveTokenEvent.fromJson(Map<String, dynamic> json) {
    // استخراج آبجکت داخلی updates
    final Map<String, dynamic> updates =
        json['updates'] as Map<String, dynamic>;

    return MoveTokenEvent(
      tokenId: updates['token_id'] as int,
      targetPosition: updates['target_position'] as int,
      hasKick: json['has_kick'] as bool? ?? false,
      kickedTokenId: updates['kicked_token_id'] as int?,
      turnStatus: updates['turn_status'] as String?,
      currentTurn: updates['current_turn'] as String?,
    );
  }

  @override
  void execute(GameController controller) async {

    await controller.handleTokenMoved(
      tokenId: tokenId,
      targetPosition: targetPosition,
      hasKick: hasKick,
      kickedTokenId: kickedTokenId,
    );
    while (controller.isMovingToken) {
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // ۲. حالا که انیمیشن تمام شده، استیت تازه و فعلی را می‌گیریم
    final freshGameState = controller.currentGameState;
    if (freshGameState?.serverState == null) return;

    // ۳. پوزیشن نهایی توکن‌ها را بر اساس داده‌های معتبر سرور آپدیت می‌کنیم
    // تا مطمئن شویم حریف و کاربر هر دو یک پوزیشن دقیق را می‌بینند
    final updatedTokens = List<Token>.from(freshGameState!.serverState!.tokens);

    // آپدیت پوزیشن مهره حرکت کرده
    final movedIndex = updatedTokens.indexWhere((t) => t.id == tokenId.toString());
    if (movedIndex != -1) {
      updatedTokens[movedIndex] = updatedTokens[movedIndex].copyWith(
        pathIndex: targetPosition,
      );
    }

    // آپدیت پوزیشن مهره خورده شده (اگر وجود دارد)
    if (hasKick && kickedTokenId != null) {
      final kickedIndex = updatedTokens.indexWhere((t) => t.id == kickedTokenId.toString());
      if (kickedIndex != -1) {
        updatedTokens[kickedIndex] = updatedTokens[kickedIndex].copyWith(
          pathIndex: -1, // برگشت به بیس
        );
      }
    }

    // ۴. ساختن استیت نهایی با استفاده از داده‌های جدید سرور و توکن‌های اصلاح‌شده
    final finalServerState = freshGameState.serverState!.copyWith(
      tokens: updatedTokens,
      turnStatus: turnStatus != null
          ? TurnStatus.values.byName(turnStatus!)
          : freshGameState.serverState!.turnStatus,
      currentTurn: currentTurn != null
          ? PlayerColor.values.byName(currentTurn!)
          : freshGameState.serverState!.currentTurn,
    );

    // ۵. اعمال نهایی روی کنترلر
    controller.updateState(
      freshGameState.copyWith(serverState: finalServerState),
    );
    final isMyTurn =
        controller.currentGameState?.serverState?.currentTurn ==
            controller.currentGameState!.livePlayer!.color &&
            controller.currentGameState?.serverState?.gameStatus ==
                GameStatus.start;
    if (isMyTurn) {
      controller.playSfx("assets/audio/sound-effect/current_turn_sound.wav");
    }
  }
}
