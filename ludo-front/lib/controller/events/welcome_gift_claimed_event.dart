import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';

class WelcomeGiftClaimedEvent extends GameEvent {
  final VpnConfig vpnConfig;

  WelcomeGiftClaimedEvent({required this.vpnConfig});

  factory WelcomeGiftClaimedEvent.fromJson(Map<String, dynamic> data) {
    return WelcomeGiftClaimedEvent(
      vpnConfig: VpnConfig.fromJson(data["newConfig"]),
    );
  }

  @override
  void execute(GameController controller) {
    final GameState? gameState = controller.currentGameState;
    final Player? livePlayer = gameState?.livePlayer;
    final List<VpnConfig> currentConfigs = livePlayer?.vpnConfigs ?? [];

    controller.updateState(
      gameState?.copyWith(
        livePlayer: livePlayer?.copyWith(
          vpnConfigs: [...currentConfigs, vpnConfig],
        ),
      ),
    );
    controller.playSfx("assets/audio/sound-effect/winner_sound.wav");
    controller.stopLoading("welcome_gift");
    controller.onWelcomeGiftClaimed?.call(vpnConfig);
  }
}
