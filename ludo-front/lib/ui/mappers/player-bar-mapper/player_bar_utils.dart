import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';

PlayerColor recognitionPlayerColor(int playerIndex, int gameMode) {
  switch (playerIndex) {
    case 0: return PlayerColor.red;
    case 1: return gameMode == 2 ? PlayerColor.yellow : PlayerColor.blue;
    case 2: return PlayerColor.yellow;
    case 3: return PlayerColor.green;
    default: return PlayerColor.red;
  }
}

Color playerUserNameBoxColor({
  required int playerIndex,
  required int numberOfPlayers,
  required PlayerColor? currentTurn,
}) {
  PlayerColor currentPlayerColor = recognitionPlayerColor(playerIndex, numberOfPlayers);

  if (currentPlayerColor == currentTurn) {
    switch (playerIndex) {
      case 0: return Colors.red.shade900;
      case 1: return numberOfPlayers == 2 ? Colors.yellow.shade700 : Colors.blue.shade300;
      case 2: return Colors.yellow.shade700;
      case 3: return Colors.green.shade400;
      default: return Colors.red;
    }
  } else {
    return Colors.black45;
  }
}