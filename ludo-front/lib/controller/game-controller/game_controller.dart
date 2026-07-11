import 'package:flutter/material.dart';
import 'package:ludo/controller/events/game_event_factory.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ludo/controller/handler/game_animation_manager.dart';
import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';

part 'game_controller.g.dart';

@riverpod
class GameController extends _$GameController {
  // Repositories & Handlers
  late final GameRepository _gameRepository;
  late final GameAnimationManager _animationManager;
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

  @override
  GameState? build() {
    final ds = SocketDataSource();
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
  void startGame({required int numberOfPlayers}) {
    _gameRepository.startGame(numberOfPlayers);
  }

  void resumeReconnection() {
    _gameRepository.resumeReconnection();
  }

  void claimDailyReward() {
    _gameRepository.claimDailyReward();
  }

  void getFastPing() {
    _gameRepository.getFastPing();
  }

  void connect(GameMode mode, String? gameId) {
    _gameRepository.connect(mode, gameId);
  }

  void moveToken(Token liveToken) {
    if (state == null) return;

    if (state!.serverState!.turnStatus == TurnStatus.waitingForMove) {
      state = state!.copyWith(
        serverState: state!.serverState!.copyWith(
          turnStatus: TurnStatus.moveTokenRequestInFlight,
        ),
      );
      _gameRepository.moveToken(liveToken);
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
      _gameRepository.rollDice();
    }
  }

  // -------------------------------------------------
  // MUSIC / SOUND PLAYER
  // -------------------------------------------------
  void playMenuMusic() {
    ref
        .read(audioServiceProvider)
        .playBackgroundMusic('assets/audio/music/join-screen-bg-music.mp3');
  }

  void playSfx(String assetName) {
    ref.read(audioServiceProvider).playSFX(assetName);
  }

  // -------------------------------------------------
  // RESET / DISPOSE
  // -------------------------------------------------
  void exitGame() {
    _gameRepository.exitGame();
  }

  void resetGame() {
    // 🟢 ۲. کالبک‌های مربوط به لیسنرهای بورد قبلی را کاملاً پاک می‌کنیم
    onInsufficientCoin = null; // 👈 اضافه شد
    onFastPingGets = null;
    onGameReady = null;
    onGameStarted = null;

    // 🟢 ۳. انیمیشن کنترلر بورد قبلی را دیسپوز می‌کنیم
    animationController?.stop();
    animationController?.dispose();
    animationController = null;

    isGameFinishedHandled = false;
    isMovingToken = false;

    // 🟢 ۴. حالا با خیال راحت استیت را پاک می‌کنیم.
    // چون isInBoard غیراکتیو شده، ویجت‌های بورد جلوی رندر خود را می‌گیرند.
    if (state?.livePlayer != null) {
      final clearedPlayer = Player(
        userId: state!.livePlayer!.userId,
        username: state!.livePlayer!.username,
        coin: state!.livePlayer!.coin,
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
