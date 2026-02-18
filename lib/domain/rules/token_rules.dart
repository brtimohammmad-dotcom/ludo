import 'package:collection/collection.dart';

import 'package:ludo/domain/model/dice.dart';
import 'package:ludo/domain/model/token.dart';

// const Map<int, int> _playerStartIndex = {
//   1: 0, // قرمز
//   2: 9, // آبی
//   3: 18, // زرد
//   4: 27, // سبز
// };
// const int _mainTrackLength = 36;
// const int _maxTrackPathIndex = 35;
//
// int _globalPlayerIndex({required int pathIndex, required int playerIndex}) {
//   return (_playerStartIndex[playerIndex]! + pathIndex) % _mainTrackLength;
// }
//
// class TokenRules {
//   final int diceValue;
//   final List<Token> tokens;
//   late final Dice _dice;
//   final int currentPlayer;
//
//   TokenRules({required this.tokens, required this.diceValue,required this.currentPlayer});
//
//   bool canActivateToken({required Token liveToken}) {
//     final targetPathIndex = liveToken.pathIndex + _dice.value;
//     bool canNotActiveToken = false;
//     tokens.any((otherToken) {
//       return canNotActiveToken =
//           currentPlayer != liveToken.player ||
//           _isCellOccupiedBySamePlayer(
//             otherToken: otherToken,
//             liveToken: liveToken,
//           ) ||
//           _isCellHasTokenInSafeCell(
//             otherToken: otherToken,
//             liveToken: liveToken,
//           ) ||
//           targetPathIndex > 39;
//     });
//     return !canNotActiveToken && (!liveToken.isInHome || _dice.value == 6);
//   }
//
//   bool _isCellOccupiedBySamePlayer({
//     required Token otherToken,
//     required Token liveToken,
//   }) {
//     final targetPathIndex = liveToken.pathIndex + _dice.value;
//
//     bool isSameToken =
//         otherToken.id != liveToken.id && otherToken.player == liveToken.player;
//     return (isSameToken) &&
//         ((otherToken.pathIndex == 0 &&
//                 liveToken.isInHome &&
//                 _dice.value == 6) ||
//             (otherToken.pathIndex == targetPathIndex &&
//                 !liveToken.isInHome &&
//                 otherToken.pathIndex != 39));
//   }
//
//   bool _isCellHasTokenInSafeCell({
//     required Token otherToken,
//     required Token liveToken,
//   }) {
//     if (otherToken.player == liveToken.player) {
//       return false;
//     }
//     final globalLiveTokenPathIndex = _globalPlayerIndex(
//       pathIndex: liveToken.pathIndex,
//       playerIndex: liveToken.player,
//     );
//     return globalLiveTokenPathIndex + _dice.value ==
//             _playerStartIndex[otherToken.player] &&
//         otherToken.pathIndex == 0;
//   }
//
//   Token? findKillTarget({required Token liveToken}) {
//     final targetPathIndex =
//         liveToken.pathIndex + diceValue;
//
//     if (targetPathIndex > _maxTrackPathIndex) {
//       return null;
//     }
//
//     final Token? killedToken = tokens.firstWhereOrNull((targetToken) {
//       final isOnMainTrack =
//           targetToken.pathIndex >= 0 &&
//           targetToken.pathIndex <= _maxTrackPathIndex;
//       final isOpponent = targetToken.player != liveToken.player;
//       if (!isOnMainTrack || !isOpponent) {
//         return false;
//       }
//       final int globalLiveTokenPath;
//       final globalTokenPath = _globalPlayerIndex(
//         pathIndex: targetToken.pathIndex,
//         playerIndex: targetToken.player,
//       );
//       if (liveToken.isInHome) {
//         globalLiveTokenPath = _globalPlayerIndex(
//           pathIndex: 0,
//           playerIndex: liveToken.player,
//         );
//       } else {
//         globalLiveTokenPath = _globalPlayerIndex(
//           pathIndex: targetPathIndex,
//           playerIndex: liveToken.player,
//         );
//       }
//       if (globalTokenPath == globalLiveTokenPath) {
//         return true;
//       }
//       return false;
//     });
//     return killedToken;
//   }
// }
