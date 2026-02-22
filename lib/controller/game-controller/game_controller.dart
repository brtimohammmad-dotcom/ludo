import 'package:flutter/cupertino.dart';
import 'package:ludo/data/data-source/socket_data_source.dart';
import 'package:ludo/data/repository/game_repository.dart';
import 'package:ludo/domain/model/player.dart';

import 'package:ludo/domain/model/state/client_game_state.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/domain/model/token.dart';

extension GameStateX on GameState {
  GameState toggleTurn() {
    return copyWith(
      serverState: serverState.copyWith(
        currentTurn: serverState.currentTurn.next,
      ),
    );
  }
}

class GameController extends ChangeNotifier {
  GameState? gameState;
  final GameRepository gameRepository = GameRepository();
  ClientState? clientState;

  GameController() {

    // Set up callbacks to update game state when socket receives updates
    gameRepository.dataSource.onStateUpdate = (ServerState state) {
        gameState = GameState(
          serverState: state,
          clientState: clientState!,
        );
        notifyListeners();
    };
    
    gameRepository.dataSource.onPlayerUpdate = (Player player) {
      clientState = ClientState(
        connectionStatus: ConnectionStatus.connected,
        diceIsRolling: false,
        tokenIsMoving: false,
        isRequestInFlight: false,
        livePlayer: player,
      );

    };
  }


  void startGame() {
    gameRepository.onConnect();
    // State will be updated via callbacks when socket connects
  }

  void moveToken(Token liveToken) {
    gameRepository.moveToken(liveToken);
  }

  void rollDice() {
    gameRepository.rollDice();
  }
  // void nextPlayer() {
  //   gameState.toggleTurn();
  //   notifyListeners();
  // }

  // Future<void> onTapToken({required Token token}) async {
  //   if (!DiceTapLock.locked.value) {
  //     return;
  //   }
  //   final tokens = tokensController.tokenNotifier.value;
  //   final liveToken = tokens.firstWhere(
  //     (item) => item.id == token.id,
  //     orElse: () => token,
  //   );
  //
  //   if (!liveToken.isActive || liveToken.player != currentTurn.value) {
  //     return;
  //   }
  //   TokenRules tokenRules = TokenRules(
  //     currentTurn: currentTurn.value,
  //     tokens: tokens,
  //     diceValue: diceController.diceValue.value.value,
  //   );
  //
  //   tokensController.tokenDisActivation();
  //   await tokensController.moveTokenSafely(
  //     liveToken: liveToken,
  //     diceController: diceController,
  //   );
  //
  //   final killedTarget = tokenRules.findKillTarget(liveToken: liveToken);
  //   if (killedTarget != null) {
  //     tokensController.killToken(targetToken: killedTarget);
  //   }
  //   if (diceController.extraMove) {
  //     diceController.extraMove = false;
  //     DiceTapLock.unlock();
  //     return;
  //   }
  //   nextPlayer();
  //   diceController.resetForNextTurn();
  // }

  // GameState rollDice(GameState centralState, Player player) {
  //   GameStatus gameStatus = centralState.serverState.gameStatus;
  //   PlayerColor currentTurn = centralState.serverState.currentTurn;
  //   final serverState = centralState.serverState;
  //   final ServerState newServerState;
  //   if (gameStatus != GameStatus.waitingForRoll) {
  //     return centralState;
  //   }
  //   if (currentTurn != player.color) {
  //     return centralState;
  //   }
  //   List<Token> tokens = centralState.serverState.tokens;
  //   int newDiceValue = Random().nextInt(6) + 1;
  //   if (newDiceValue == 6) {
  //     extraMove = true;
  //   }
  //   TokenRules tokenRules = TokenRules(
  //     tokens: tokens,
  //     diceValue: newDiceValue,
  //     currentTurn: currentTurn,
  //   );
  //   final updatedTokenList = tokens.map((token) {
  //     final canActivate = tokenRules.canActivateToken(liveToken: token);
  //     return token.copyWith(newIsActive: canActivate);
  //   }).toList();
  //   PlayerRules playerRules = PlayerRules();
  //   if (playerRules.canActivePlayer(tokens: updatedTokenList)) {
  //     newServerState = serverState.copyWith(
  //       gameStatus: GameStatus.waitingForMove,
  //       tokens: updatedTokenList,
  //       diceValue: newDiceValue,
  //     );
  //     return centralState.copyWith(serverState: newServerState);
  //   }
  //   if (extraMove) {
  //     newServerState = serverState.copyWith(
  //       gameStatus: GameStatus.waitingForRoll,
  //       diceValue: newDiceValue,
  //     );
  //     return centralState.copyWith(serverState: newServerState);
  //   }
  //   newServerState = serverState.copyWith(
  //     gameStatus: GameStatus.waitingForRoll,
  //     currentTurn: (currentTurn + 1) % 4,
  //     extraMove: false,
  //     dicePathIndex: (dicePathIndex + 1) % 4,
  //     diceValue: newDiceValue,
  //   );
  //   return centralState.copyWith(serverState: newServerState);
  // }
  
  @override
  void dispose() {
    gameRepository.dispose();
    super.dispose();
  }
}
