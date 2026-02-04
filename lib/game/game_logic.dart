class GameLogic {
  int currentPlayerActiveNumber = 1;

  void currentPlayerChanger() {
    if (currentPlayerActiveNumber < 4) {
      currentPlayerActiveNumber++;
    } else {
      currentPlayerActiveNumber = 1;
    }
  }
}
