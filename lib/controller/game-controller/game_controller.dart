import 'package:flutter/cupertino.dart';

class GameController {
ValueNotifier<int> currentPlayer=ValueNotifier(1);
  void nextPlayer() {
    currentPlayer.value = currentPlayer.value % 4 + 1;
  }
}