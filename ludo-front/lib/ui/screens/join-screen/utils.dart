  import 'package:flutter/material.dart';

  class JoinScreenLayout {
    final double screenHeight;
    final double screenWidth;
    final double boardSize;
    late final double _diceSize;

    JoinScreenLayout(BuildContext context)
        : screenHeight = MediaQuery.of(context).size.height,
          screenWidth = MediaQuery.of(context).size.width,
          boardSize = (MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height * 0.8) {
      // بازنشانی مقدار تاس با سقف مشخص
      _diceSize = (boardSize * 0.4).clamp(120.0, 220.0);
    }

    double get diceSize => _diceSize;
  }