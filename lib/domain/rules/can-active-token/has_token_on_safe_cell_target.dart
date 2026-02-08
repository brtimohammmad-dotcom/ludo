import 'package:ludo/domain/model/token.dart';

bool hasTokenOnTargetSafeCell(
    {required List<Token> tokens,required Token token,required int targetPathIndex}){
  return tokens.any((other) {
    switch (token.player) {
      case 1:
        if (targetPathIndex == 13 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 2:
        if (targetPathIndex == 13 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 3:
        if (targetPathIndex == 13 &&
            other.player == 4 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      case 4:
        if (targetPathIndex == 13 &&
            other.player == 1 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 26 &&
            other.player == 2 &&
            other.pathIndex == 0) {
          return true;
        } else if (targetPathIndex == 39 &&
            other.player == 3 &&
            other.pathIndex == 0) {
          return true;
        } else {
          return false;
        }
      default:
        throw Exception('invalid Player');
    }
  });
}