import 'package:flutter/material.dart';

class TokenHomeMap {
  final int startMapRow;
  final int startMapColumn;

  TokenHomeMap({required this.startMapRow, required this.startMapColumn});
}

List<TokenHomeMap> homes = [
  TokenHomeMap(startMapRow: 0, startMapColumn: 0),
  TokenHomeMap(startMapRow: 0, startMapColumn: 7),
  TokenHomeMap(startMapRow: 7, startMapColumn: 0),
  TokenHomeMap(startMapRow: 7, startMapColumn: 7),
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
    gradient: RadialGradient(colors: [Colors.blueAccent, Colors.blue]),
  ),
  TokenColorizeHomeMap(
    startMapRow: 7,
    startMapColumn: 0,
    gradient: RadialGradient(colors: [Colors.redAccent, Colors.red]),
  ),
  TokenColorizeHomeMap(
    startMapRow: 0,
    startMapColumn: 7,
    gradient: RadialGradient(colors: [Colors.yellowAccent, Colors.yellow]),
  ),
  TokenColorizeHomeMap(
    startMapRow: 7,
    startMapColumn: 7,
    gradient: RadialGradient(
      colors: [Colors.greenAccent.shade400, Colors.green],
    ),
  ),
];
