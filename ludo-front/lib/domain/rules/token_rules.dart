import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

class TokenRules {
  static final Map<PlayerColor, int> _playerStartIndex = {
    PlayerColor.red: 0,
    PlayerColor.blue: 9,
    PlayerColor.yellow: 18,
    PlayerColor.green: 27,
  };
  static final int _mainTrackLength = 36;

  // تبدیل موقعیت محلی به موقعیت جهانی روی صفحه اصلی
  static int _globalPlayerIndex({
    required int pathIndex,
    required PlayerColor playerColor,
  }) {
    return (_playerStartIndex[playerColor]! + pathIndex) % _mainTrackLength;
  }

  static bool canActiveToken(Token liveToken, GameState? gameState) {
    if (gameState?.serverState == null) return false;

    final serverState = gameState!.serverState!;

    // ۱. بررسی نوبت بازیکن و وضعیت بازی
    if (serverState.turnStatus != TurnStatus.waitingForMove) return false;
    if (serverState.currentTurn != liveToken.playerColor) return false;
    if (serverState.turnStatus == TurnStatus.waitingForRoll) return false;

    final dice = serverState.lastDiceValue.toInt();

    // ۲. محاسبه موقعیت مسیر بعدی مهره
    // اگر مهره داخل خانه باشد (-1)، با تاس ۶ به خانه 0 می‌رود، در غیر این صورت جلو می‌رود
    final targetPathIndex = liveToken.pathIndex == -1
        ? (dice == 6 ? 0 : -1)
        : liveToken.pathIndex + dice;

    // اگر تاس ۶ نباشد و مهره داخل خانه باشد، یا مهره از انتهای نقشه (39) رد شود، غیرفعال است
    if (liveToken.pathIndex == -1 && dice != 6) return false;
    if (targetPathIndex > 39) return false;

    // ۳. بررسی قوانین برخورد با سایر مهره‌ها (تداخل با مهره خودی یا حریف در خانه امن)
    bool hasConflict = serverState.tokens.any((otherToken) {
      // الف: بررسی اشغال شدن مقصد توسط مهره‌ی خودی
      final isOccupiedBySame = _isCellOccupiedBySamePlayer(
        gameState: gameState,
        liveToken: liveToken,
        otherToken: otherToken,
        targetPathIndex: targetPathIndex,
      );

      // ب: بررسی وجود مهره‌ی حریف در خانه امن مقصد
      final isTargetSafeCell = _isCellHasTokenInSafeCell(
        gameState: gameState,
        liveToken: liveToken,
        otherToken: otherToken,
      );

      return isOccupiedBySame || isTargetSafeCell;
    });

    return !hasConflict;
  }

  static bool _isCellOccupiedBySamePlayer({
    required Token liveToken,
    required Token otherToken,
    required GameState gameState,
    required int targetPathIndex,
  }) {
    // مهره باید هم‌رنگ باشد و خودش نباشد
    if (otherToken.id == liveToken.id || otherToken.playerColor != liveToken.playerColor) {
      return false;
    }

    // مهره خودی در مقصد باشد (با این شرط که مقصد خانه نهایی 39 نباشد چون در خانه نهایی مهره‌ها روی هم سوار می‌شوند)
    return otherToken.pathIndex == targetPathIndex && targetPathIndex != 39;
  }

  static bool _isCellHasTokenInSafeCell({
    required Token liveToken,
    required Token otherToken,
    required GameState gameState,
  }) {
    // اگر مهره هم‌رنگ باشد، قانون خانه امن حریف معنی ندارد
    if (otherToken.playerColor == liveToken.playerColor) return false;

    // مهره حریف حتماً باید در خانه شروع خودش (یعنی صفر) باشد تا امن حساب شود
    if (otherToken.pathIndex != 0) return false;

    final dice = gameState.serverState!.lastDiceValue.toInt();

    // محاسبه موقعیت جهانی (Global Index) مقصد مهره ما
    int targetGlobalIndex;
    if (liveToken.pathIndex == -1) {
      // اگر مهره در خانه است، مقصدش نقطه شروع خودش است
      targetGlobalIndex = _playerStartIndex[liveToken.playerColor]!;
    } else {
      // اگر مهره در زمین است، آیا بعد از حرکت هنوز روی مسیر اصلی (کمتر از ۳۶) قرار دارد؟
      if (liveToken.pathIndex + dice >= _mainTrackLength) {
        // وارد مسیر اختصاصی خانه شده و دیگر ربطی به خانه امن اصلی حریف ندارد
        return false;
      }
      targetGlobalIndex = _globalPlayerIndex(
        pathIndex: liveToken.pathIndex + dice,
        playerColor: liveToken.playerColor,
      );
    }

    // موقعیت جهانی خانه امن حریف (نقطه شروع حریف)
    final opponentStartGlobalIndex = _playerStartIndex[otherToken.playerColor]!;

    // اگر مقصد حرکت ما دقیقاً برابر با نقطه شروع حریف باشد، حق حرکت نداریم
    return targetGlobalIndex == opponentStartGlobalIndex;
  }
}