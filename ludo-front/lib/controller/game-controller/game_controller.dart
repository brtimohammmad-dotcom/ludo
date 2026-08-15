import 'package:flutter/material.dart';
import 'package:ludo/controller/active_emoji_notifier/active_emoji_notifier.dart';
import 'package:ludo/controller/events/game_event_factory.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/controller/leader_board/leader_board.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ludo/controller/handler/game_animation_manager.dart';
import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  // Repositories & Handlers
  late final GameRepository _gameRepository;
  late final GameAnimationManager _animationManager;
  late final GameType gameType;
  String? gameId;
  AnimationController? animationController;

  // Flags & Internal States
  bool isGameFinishedHandled = false;
  bool isMovingToken = false;
  VoidCallback? onFastPingGets;
  VoidCallback? onGameReady;
  VoidCallback? onGameStarted;
  VoidCallback? onInsufficientCoin;
  VoidCallback? onReconnectionFailed;
  VoidCallback? onConnect;
  Function(VpnConfig subsribtionLink)? onVpnRedeemed;

  @override
  GameState? build() {
    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      TelegramWebApp.instance.expand();

      final startParam = TelegramWebApp.instance.initDataUnsafe?.startParam;
      if (startParam != null && startParam.startsWith("game_")) {
        gameId = startParam.replaceAll("game_", "");
        gameType = GameType.friendly;
      } else {
        gameType = GameType.global;
      }
    } else {
      gameType = GameType.global;
    }
    final ds = SocketDataSource(gameType: gameType, gameId: gameId);
    _gameRepository = GameRepository(ds);

    // مقداردهی هندلرها با پاس دادن instance فعلی
    _animationManager = GameAnimationManager(this);

    _gameRepository.dataSource;
    ds.onGameEventReceived = (String eventName, Map<String, dynamic> data) {
      final event = GameEventFactory.create(eventName, data);
      if (event != null) {
        event.execute(this);
      }
    };
    // 🧹 مدیریت Dispose خودکار در ریورپاد
    ref.onDispose(() {
      animationController?.stop();
      animationController?.dispose();
      animationController = null;
    });

    // وضعیت اولیه در بدو شروع بازی null است
    return null;
  }

  // -------------------------------------------------
  // INTERNAL HELPERS (صرفا برای استفاده کامپوننت‌های کمکی)
  // -------------------------------------------------
  GameState? get currentGameState => state;

  void updateState(GameState? newState) {
    state = newState;
  }

  void updateLeaderBoard(Map<String, dynamic> jsonData) {
    ref.read(leaderboardDataProvider.notifier).updateData(jsonData);
  }

  void showEmoji(PlayerColor color, String emoji) {
    ref.read(activeEmojiProvider.notifier).showEmoji(color, emoji);
  }

  void clearAllLoadings() {
    ref.read(globalLoadingProvider.notifier).clearAll();
  }

  void stopLoading(String key) {
    ref.read(globalLoadingProvider.notifier).stop(key);
  }

  void startLoading(String key) {
    ref.read(globalLoadingProvider.notifier).start(key);
  }

  // -------------------------------------------------
  // ANIMATION BRIDGE
  // -------------------------------------------------
  Future<void> handleTokenMoved({
    required int tokenId,
    required bool hasKick,
    int? kickedTokenId,
    required int targetPosition,
  }) async {
    if (isMovingToken || state?.livePlayer == null) return;
    isMovingToken = true;
    try {
      animationController?.stop();
      await _animationManager.moveTokenStepByStep(
        tokenId: tokenId,
        targetPosition: targetPosition,
      );
      animationController?.reset();
      animationController?.forward();
    } finally {
      isMovingToken = false;
    }
  }

  Future<void> handleDiceRolled(ServerState newState) async {
    await _animationManager.animateDiceRoll(newState);
  }

  // -------------------------------------------------
  // PUBLIC API
  // -------------------------------------------------
  void startGame({
    required int numberOfPlayers,
    required GameType gameType,
    required GameLevel gameLevel,
  }) {
    _gameRepository.startGame(numberOfPlayers, gameType, gameLevel, (_) {});
  }

  void requestGameState() {
    _gameRepository.requestGameState();
  }

  void resumeReconnection() {
    _gameRepository.resumeReconnection();
  }

  void claimDailyReward() {
    _gameRepository.claimDailyReward((response) {
      if (response['success'] == false) {
        stopLoading("daily_reward");
      }
    });
  }

  void getLeaderBoardList() {
    _gameRepository.getLeaderBoardList((response) {
      if (response['success'] == false) {
        stopLoading("leader_board_loading");
      }
    });
  }

  void sendEmoji(String emojiName) {
    _gameRepository.sendEmoji(emojiName);
  }

  void getFastPing() {
    _gameRepository.getFastPing();
  }

  void connect() {
    _gameRepository.connect();
  }

  void moveToken(Token liveToken) {
    if (state == null) return;

    if (state!.serverState!.turnStatus == TurnStatus.waitingForMove) {
      state = state!.copyWith(
        serverState: state!.serverState!.copyWith(
          turnStatus: TurnStatus.moveTokenRequestInFlight,
        ),
      );
      _gameRepository.moveToken(liveToken, (response) {
        if (response['success'] == false) {
          requestGameState();
        }
      });
      final diceValue = state!.serverState!.lastDiceValue;

      // اجرای انیمیشن به صورت Async و موازی با درخواست سرور
      _animationManager.moveTokenStepByStepLocally(liveToken.id, diceValue);
    }
  }

  void rollDice() {
    if (state == null) return;

    if (state.isMyTurnToRoll) {
      state = state!.copyWith(
        serverState: state!.serverState!.copyWith(
          turnStatus: TurnStatus.rollDiceRequestInFlight,
        ),
      );
      _gameRepository.rollDice((response) {
        if (response['success'] == false) {
          requestGameState();
        }
      });
    }
  }

  // -------------------------------------------------
  // MUSIC / SOUND PLAYER
  // -------------------------------------------------
  void playMenuMusic() {
    ref
        .read(audioServiceProvider.notifier)
        .playBackgroundMusic('assets/audio/music/join-screen-bg-music.mp3');
  }

  void stopMenuMusic() {
    ref.read(audioServiceProvider.notifier).stopBackgroundMusic();
  }

  void playSfx(String assetName) {
    ref.read(audioServiceProvider.notifier).playSFX(assetName);
  }

  // -------------------------------------------------
  // VPN / COIN
  // -------------------------------------------------
  void redeemVpn({required int gb}) {
    _gameRepository.redeemVpn(gb, (response) {
      if (response['success'] == false) {
        stopLoading("redeem_vpn");
      }
    });
  }

  // -------------------------------------------------
  // RESET / DISPOSE
  // -------------------------------------------------
  void exitGame() {
    _gameRepository.exitGame((response) {
      if (response['success'] == false) {
        stopLoading("exit_game");
      }
    });
  }

  void resetGame() {
    onInsufficientCoin = null;
    onFastPingGets = null;
    onGameReady = null;
    onGameStarted = null;

    animationController?.stop();
    animationController?.dispose();
    animationController = null;

    isGameFinishedHandled = false;
    isMovingToken = false;

    if (state?.livePlayer != null) {
      final clearedPlayer = Player(
        wins: state!.livePlayer!.wins,
        losses: state!.livePlayer!.losses,
        userId: state!.livePlayer!.userId,
        username: state!.livePlayer!.username,
        canClaimDailyReward: state!.livePlayer!.canClaimDailyReward,
        rewardStreak: state!.livePlayer!.rewardStreak,
        coin: state!.livePlayer!.coin,
        avatarUrl: state!.livePlayer!.avatarUrl,
        color: null,
        playerStatus: null,
        numberOfAbsences: 0,
      );
      state = GameState(
        serverState: null,
        livePlayer: clearedPlayer,
        gameStage: GameStage.joinStage,
      );
    } else {
      state = null;
    }
  }
}
