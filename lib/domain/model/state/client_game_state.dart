enum ConnectionStatus { disconnected, connecting, connected, reconnecting}

class ClientState {
  final ConnectionStatus connectionStatus;
  final bool diceIsRolling;
  final bool tokenIsMoving;
  final bool isRequestInFlight;

  ClientState({
    required this.connectionStatus,
    required this.diceIsRolling,
    required this.tokenIsMoving,
    required this.isRequestInFlight,
  });

  ClientState copyWith({
    ConnectionStatus? connectionStatus,
    bool? diceIsRolling,
    bool? tokenIsMoving,
    bool? isRequestInFlight,
  }) {
    return ClientState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      diceIsRolling: diceIsRolling ?? this.diceIsRolling,
      tokenIsMoving: tokenIsMoving ?? this.tokenIsMoving,
      isRequestInFlight: isRequestInFlight ?? this.isRequestInFlight,
    );
  }
}
