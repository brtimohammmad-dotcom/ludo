import 'package:ludo/domain/model/state/client_game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

class CentralState {
  final ClientState clientState;
  final ServerState serverState;

  CentralState({required this.serverState, required this.clientState});

  CentralState copyWith({ClientState? clientState, ServerState? serverState}) {
    return CentralState(
      serverState: serverState ?? this.serverState,
      clientState: clientState ?? this.clientState,
    );
  }
}
