import 'package:flutter/material.dart';

class TokenHomeMap {
  final int startMapRow;
  final int startMapColumn;

  TokenHomeMap({required this.startMapRow, required this.startMapColumn});
}

List<TokenHomeMap> homes = [
  TokenHomeMap(startMapRow: 1, startMapColumn: 1),
  TokenHomeMap(startMapRow: 1, startMapColumn: 10),
  TokenHomeMap(startMapRow: 10, startMapColumn: 1),
  TokenHomeMap(startMapRow: 10, startMapColumn: 10),
];

class TokenColorizeHomeMap {
  final Gradient gradient;
  final int startMapRow;
  final int startMapColumn;

  TokenColorizeHomeMap({
    required this.startMapRow,
    required this.startMapColumn,
    required this.gradient,
  });
}

List<TokenColorizeHomeMap> colorizeHomes = [
  TokenColorizeHomeMap(
    startMapRow: 0,
    startMapColumn: 0,
    gradient: RadialGradient(
      colors: [Colors.blueAccent, Colors.blue ],
    ),
  ),
  TokenColorizeHomeMap(
    startMapRow: 9,
    startMapColumn: 0,
    gradient: RadialGradient(
      colors: [Colors.redAccent, Colors.red],
    ),
  ),
  TokenColorizeHomeMap(
    startMapRow: 0,
    startMapColumn: 9,
    gradient: RadialGradient(
      colors: [Colors.yellowAccent, Colors.yellow],
    ),
  ),
  TokenColorizeHomeMap(
    startMapRow: 9,
    startMapColumn: 9,
    gradient: RadialGradient(
      colors: [Colors.greenAccent.shade400, Colors.green],
    ),
  ),
];
