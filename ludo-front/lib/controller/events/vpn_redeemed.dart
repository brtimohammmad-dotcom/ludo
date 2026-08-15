import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';

class VpnRedeemed extends GameEvent {
  final VpnConfig vpnConfig;

  VpnRedeemed({required this.vpnConfig});

  factory VpnRedeemed.fromJson(Map<String, dynamic> data) {
    return VpnRedeemed(vpnConfig: VpnConfig.fromJson(data["newConfig"]));
  }

  final Map<int, int> vpnCost = {1: 10000, 3: 25000, 5: 40000};

  @override
  void execute(GameController controller) {
    final GameState? gameState = controller.currentGameState;
    final Player? livePlayer = gameState?.livePlayer;
    final List<VpnConfig> currentConfigs = livePlayer?.vpnConfigs ?? [];

    controller.updateState(
      gameState?.copyWith(
        livePlayer: livePlayer?.copyWith(
          vpnConfigs: [...currentConfigs, vpnConfig],
          coin: livePlayer.coin - vpnCost[vpnConfig.totalGb]!,
        ),
      ),
    );
    controller.stopLoading("redeem_vpn");
    controller.onVpnRedeemed?.call(vpnConfig);
  }
}
