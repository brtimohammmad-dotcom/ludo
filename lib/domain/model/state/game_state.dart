import 'package:ludo/domain/model/state/client_game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class GameState {
  final ClientState clientState;
  final ServerState serverState;

  GameState({required this.serverState, required this.clientState});

  GameState copyWith({ClientState? clientState, ServerState? serverState}) {
    return GameState(
      serverState: serverState ?? this.serverState,
      clientState: clientState ?? this.clientState,
    );
  }
}
