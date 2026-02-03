import 'package:flutter/material.dart';
import 'package:ludo/domain/model/token.dart';

Gradient tokenGradient(Token token) {
  switch (token.id) {
    case >=1&&<=4:
      return const RadialGradient(colors: [Colors.red, Colors.redAccent]);
    case >=4&&<=8:
      return const RadialGradient(colors: [Colors.blue, Colors.blueAccent]);
    case >=8&&<=12:
      return const RadialGradient(colors: [Colors.yellow, Colors.yellowAccent]);
    case >=12&&<=16:
      return RadialGradient(
          colors: [Colors.green, Colors.green.withGreen(200)]);
    default:
      throw Exception('invalid Player');
  }
}
