import 'package:flutter/material.dart';
import 'package:ludo/game/logic/token-logic/blue_logic.dart';
import 'package:ludo/game/logic/token-logic/green_logic.dart';
import 'package:ludo/game/logic/token-logic/red_logic.dart';
import 'package:ludo/game/logic/token-logic/yellow_logic.dart';


Map<int, List<Offset>> homePaths = {
  1: redHomePath,
  2: blueHomePath,
  3: yellowHomePath,
  4: greenHomePath,
};
Map<int, List<Offset>> movementPaths = {
  1: redPath,
  2: bluePath,
  3: yellowPath,
  4: greenPath,
};
