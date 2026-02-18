import 'package:flutter/material.dart';
import 'package:ludo/controller/dice-controller/dice_controller.dart';

import 'package:ludo/domain/rules/token_rules.dart';
import 'package:ludo/domain/model/token.dart';

// class TokensController {
//   bool isMoving = false;
//   final ValueNotifier<List<Token>> tokenNotifier = ValueNotifier<List<Token>>(
//     tokens,
//   );
//
//   void killToken({required Token targetToken}) {
//     List<Token> newList = List<Token>.from(tokenNotifier.value);
//     newList[targetToken.id - 1] = targetToken.copyWith(newPathIndex: -1);
//     tokenNotifier.value = newList;
//   }
//
//   void updateTokenActivation({
//     required DiceController diceController,
//     required int currentPlayer
//   }) {
//     TokenRules tokenRules = TokenRules(
//       currentPlayer: currentPlayer,
//       tokens: tokenNotifier.value,
//        diceValue: diceController.diceValue.value.value,
//     );
//     final newTokenList = List<Token>.from(tokenNotifier.value);
//     final updatedTokenList = newTokenList.map((token) {
//       final canActivate = tokenRules.canActivateToken(liveToken: token);
//       return token.copyWith(newIsActive: canActivate);
//     }).toList();
//     tokenNotifier.value = updatedTokenList;
//   }
//
//   void tokenDisActivation() {
//     final newTokenList = List<Token>.from(tokenNotifier.value);
//     final updatedTokenList = newTokenList.map((token) {
//       return token.copyWith(newIsActive: false);
//     }).toList();
//     tokenNotifier.value = updatedTokenList;
//   }
//
//   Future<void> moveTokenSafely({
//     required Token liveToken,
//     required DiceController diceController,
//   }) async {
//     bool isInHome = liveToken.isInHome;
//     if (isMoving) {
//       return;
//     }
//     if (isInHome) {
//       await moveTokenToStartCell(
//         diceController: diceController,
//         liveToken: liveToken,
//       );
//     } else {
//       await moveTokenStepByStep(
//         liveToken: liveToken,
//         diceController: diceController,
//       );
//     }
//   }
//
//   Future<void> moveTokenStepByStep({
//     required Token liveToken,
//     required DiceController diceController,
//   }) async {
//     int steps = diceController.diceValue.value.value;
//     if (isMoving) {
//       return;
//     }
//     isMoving = true;
//     List<Token> current = List.from(tokenNotifier.value);
//
//     int index = current.indexWhere((t) => t.id == liveToken.id);
//     Token token = current[index];
//     for (int i = 0; i < steps; i++) {
//       token = token.copyWith(newPathIndex: token.pathIndex + 1);
//       current[index] = token;
//       tokenNotifier.value = List.from(current);
//
//       await Future.delayed(const Duration(milliseconds: 300));
//     }
//
//     isMoving = false;
//   }
//
//   Future<void> moveTokenToStartCell({
//     required DiceController diceController,
//     required Token liveToken,
//   }) async {
//     isMoving = true;
//     List<Token> newTokenNotifier = List<Token>.from(tokenNotifier.value);
//     int index = newTokenNotifier.indexWhere((t) => t.id == liveToken.id);
//
//     newTokenNotifier[index] = newTokenNotifier[index]
//         .copyWith(newPathIndex: 0);
//     tokenNotifier.value = newTokenNotifier;
//     await Future.delayed(const Duration(milliseconds: 300));
//
//     isMoving = false;
//   }
// }
