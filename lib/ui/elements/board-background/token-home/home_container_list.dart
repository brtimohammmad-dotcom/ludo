import 'package:flutter/material.dart';
import 'package:ludo/ui/elements/board-background/token-home/get_token_home.dart';

List<Positioned> getHomeContainerList(double cellSize, double tokenHomeSize) {
  return [
    ...homes.map((home) {
      return Positioned(
        left: home.startMapColumn * cellSize,
        top: home.startMapRow * cellSize,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: RadialGradient(
              colors: [Color(0xffD5B195).withAlpha(50),Color(0xffD5B195).withAlpha(100),],
            ),
          ),
          width: tokenHomeSize,
          height: tokenHomeSize,
        ),
      );
    }),
  ];
}

List<Positioned> getColorizeHomeContainerList(double cellSize, double tokenHomeSize) {
  return [
    ...colorizeHomes.map((home) {
      return Positioned(
        left: home.startMapColumn * cellSize,
        top: home.startMapRow * cellSize,
        child: Container(
          decoration: BoxDecoration(
            gradient: home.gradient
          ),
          width: tokenHomeSize,
          height: tokenHomeSize,
        ),
      );
    }),
  ];
}
