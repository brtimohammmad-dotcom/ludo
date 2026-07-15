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
      case 0: return const Color(0xFFFF5252); // قرمز نئونی روشن
      case 1: return numberOfPlayers == 2 ? const Color(0xFFFFD740) : const Color(0xFF40C4FF); // زرد یا آبی روشن
      case 2: return const Color(0xFFFFD740); // زرد روشن
      case 3: return const Color(0xFF69F0AE); // سبز روشن
      default: return Colors.white;
    }
  } else {
    // ❄️ تغییر از مشکی مرده به سفید یخی ملایم برای خوانایی در پس‌زمینه تاریک
    return const Color(0xB3FFFFFF);
  }
}