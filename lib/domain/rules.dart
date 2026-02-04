bool canMove({
  required int diceIndex,
  required bool isInHome,
  required tokenPlayer,
  required int currentPlayer,
}) {
  if (diceIndex == 6 && isInHome && tokenPlayer == currentPlayer) {
    return true;
  } else {
    return false;
  }
}
