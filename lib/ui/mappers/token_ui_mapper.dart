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
        colors: [Colors.green, Colors.green.withGreen(200)],
      );
    default:
      throw Exception('invalid Player');
  }
}

List<BoxShadow> activeTokenShadow(Token token) {
  double colorBlurRadius=9;
  switch (token.player) {
    case 1:
      return [
        BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 1),
        BoxShadow(color: Colors.red, blurRadius: colorBlurRadius, spreadRadius: 2),

      ];
    case 2:
      return [
        BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 1),
        BoxShadow(color: Colors.blue, blurRadius: colorBlurRadius, spreadRadius: 2),

      ];
    case 3:
      return [
        BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 1),
        BoxShadow(color: Colors.yellow, blurRadius: colorBlurRadius, spreadRadius: 2),

      ];
    case 4:
      return [
        BoxShadow(color: Colors.white, blurRadius: 8, spreadRadius: 4),
        BoxShadow(color: Colors.green, blurRadius: colorBlurRadius, spreadRadius: 2),

      ];
    default:
      throw Exception('invalid Player');
  }
}
