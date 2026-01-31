import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';

Gradient tokenGradient(Token token) {
  switch (token.player) {
    case 1:
      return const RadialGradient(colors: [Colors.red, Colors.redAccent]);
    case 2:
      return const RadialGradient(colors: [Colors.blue, Colors.blueAccent]);
    case 3:
      return const RadialGradient(colors: [Colors.yellow, Colors.yellowAccent]);
    case 4:
      return RadialGradient(
          colors: [Colors.green, Colors.green.withGreen(200)]);
    default:
      throw Exception('invalid Player');
  }
}
