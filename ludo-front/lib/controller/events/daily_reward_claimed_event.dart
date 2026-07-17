import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class DailyRewardClaimedEvent implements GameEvent {
  final int coin;

  DailyRewardClaimedEvent({required this.coin});

  factory DailyRewardClaimedEvent.fromJson(Map<String, dynamic> data) {
    return DailyRewardClaimedEvent(coin: data["coin"] as int);
  }

  @override
  void execute(GameController controller) {
    final livePlayer = controller.currentGameState?.livePlayer;
    controller.stopLoading('daily_reward');
    controller.playSfx("assets/audio/sound-effect/claim_daily_reward_sound.wav");
    controller.updateState(
      controller.currentGameState?.copyWith(
        livePlayer: livePlayer?.copyWith(
          coin: coin,
          canClaimDailyReward: false,
          rewardStreak: livePlayer.rewardStreak + 1,
        ),
      ),
    );
  }
}
