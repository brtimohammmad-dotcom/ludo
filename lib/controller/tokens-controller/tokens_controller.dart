import 'package:flutter/material.dart';
import 'package:ludo/domain/state/tokens_state.dart';
import 'package:ludo/domain/model/token.dart';

class TokensController {
  bool isMoving=false;
  final ValueNotifier<List<Token>> tokenNotifier = ValueNotifier<List<Token>>(
    tokens,
  );

}