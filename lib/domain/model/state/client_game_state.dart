import 'package:ludo/domain/model/player.dart';

enum ConnectionStatus { disconnected, connecting, connected, reconnecting }

class ClientState {
  final Player livePlayer;
  final ConnectionStatus connectionStatus;
  final bool diceIsRolling;
  final bool tokenIsMoving;
  final bool isRequestInFlight;

  ClientState({
    required this.connectionStatus,
    required this.diceIsRolling,
    required this.tokenIsMoving,
    required this.isRequestInFlight,
    required this.livePlayer,
  });

  ClientState copyWith({
    Player? livePlayer,
    ConnectionStatus? connectionStatus,
    bool? diceIsRolling,
    bool? tokenIsMoving,
    bool? isRequestInFlight,
  }) {
    return ClientState(
      livePlayer: livePlayer ?? this.livePlayer,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      diceIsRolling: diceIsRolling ?? this.diceIsRolling,
      tokenIsMoving: tokenIsMoving ?? this.tokenIsMoving,
      isRequestInFlight: isRequestInFlight ?? this.isRequestInFlight,
    );
  }
}
