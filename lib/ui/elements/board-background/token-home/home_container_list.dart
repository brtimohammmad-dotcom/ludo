import 'package:flutter/material.dart';
import 'package:ludo/ui/elements/board-background/token-home/get_token_home.dart';

List<Positioned> getHomeContainerList(double cellSize, double tokenHomeSize) {
  return [
    ...homes.map((home) {
      return Positioned(
        left: home.startMapColumn * cellSize,
        top: home.startMapRow * cellSize,
        child: SizedBox(
          width: tokenHomeSize,
          height: tokenHomeSize,
          child: Container(
            margin: EdgeInsets.all(cellSize/2.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cellSize/2),
              gradient: RadialGradient(
                colors: [
                  const Color(0xffD5B195).withAlpha(50),
                  const Color(0xffD5B195).withAlpha(100),
                ],
              ),
            ),

          ),
        ),
      );
    }),
  ];
}

List<Positioned> getColorizeHomeContainerList(
  double cellSize,
  double tokenHomeSize,
) {
  return [
    ...colorizeHomes.map((home) {
      return Positioned(
        left: home.startMapColumn * cellSize,
        top: home.startMapRow * cellSize,
        child: Container(
          decoration: BoxDecoration(gradient: home.gradient),
          width: tokenHomeSize,
          height: tokenHomeSize,
        ),
      );
    }),
  ];
}
