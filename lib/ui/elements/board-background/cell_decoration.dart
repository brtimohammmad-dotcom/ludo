import 'package:flutter/material.dart';
bool isCenterCell(int r, int c) {
  return r >= 4 && r <= 6 && c >= 4 && c <= 6;
}

Gradient getColor(int r, int c) {
  // قرمز
  if (r > 6 && c == 5 || r == 10 && c == 4) {
    return RadialGradient(
      colors: [Colors.red.shade500.withBlue(80).withGreen(90), Colors.red],
    );
  }

  // سبز
  if (r == 5 && c > 6 || r == 6 && c == 10) {

  return RadialGradient(
      colors: [Colors.green.shade500.withGreen(185), Colors.green],
    );
  }

  // آبی
  if (r == 5 && c < 4 || r == 4 && c == 0) {
    return RadialGradient(
      colors: [Colors.blue.shade500.withGreen(165), Colors.blue],
    );
  }

  // زرد
  if (r < 4 && c == 5 || r == 0 && c == 6) {

    return RadialGradient(
      colors: [Colors.yellow.shade500.withGreen(250), Colors.yellow],
      radius: 0.6,
    );
  }
  return RadialGradient(
    colors: [Color(0xffD5B195).withAlpha(180), Color(0xffD5B195)],
  );
}

//Colors.brown, Colors.brown.shade700
