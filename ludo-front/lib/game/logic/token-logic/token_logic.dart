import 'package:flutter/material.dart';
import 'package:ludo/game/logic/token-logic/blue_logic.dart';
import 'package:ludo/game/logic/token-logic/green_logic.dart';
import 'package:ludo/game/logic/token-logic/red_logic.dart';
import 'package:ludo/game/logic/token-logic/yellow_logic.dart';


Map<int, List<Offset>> homePaths = {
  0: redHomePath,
  1: blueHomePath,
  2: yellowHomePath,
  3: greenHomePath,
};
Map<int, List<Offset>> movementPaths = {
  0: redPath,
  1: bluePath,
  2: yellowPath,
  3: greenPath,
};
