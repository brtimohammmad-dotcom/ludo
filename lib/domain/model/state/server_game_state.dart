import 'package:ludo/domain/model/token.dart';

enum GameStatus { waitingForRoll, waitingForMove, finished }

class ServerState {
  final List<Token> tokens;
  final int? diceValue;
  final int currentPlayer;
  final GameStatus gameStatus;

  ServerState({
    required this.tokens,
    required this.diceValue,
    required this.currentPlayer,
    required this.gameStatus,
  });

  ServerState copyWith({
    List<Token>? tokens,
    int? diceValue,
    int? currentPlayer,
    GameStatus? gameStatus,
  }) {
    return ServerState(
      diceValue: diceValue ?? this.diceValue,
      tokens: tokens ?? this.tokens,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      gameStatus: gameStatus ?? this.gameStatus,
    );
  }
}
