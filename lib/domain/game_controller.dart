class GameController {
  int currentPlayer;

  GameController({required this.currentPlayer});

  void nextPlayer() {
    currentPlayer = currentPlayer % 4 + 1;
  }
}
