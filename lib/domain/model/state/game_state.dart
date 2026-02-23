import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class GameState {
  final Player livePlayer;
  final ServerState serverState;

  GameState({required this.serverState, required this.livePlayer});

  GameState copyWith({Player? livePlayer, ServerState? serverState}) {
    return GameState(
      serverState: serverState ?? this.serverState,
      livePlayer: livePlayer ?? this.livePlayer,
    );
  }
}
