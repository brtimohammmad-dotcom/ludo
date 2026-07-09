import 'package:flutter/material.dart';
import 'package:ludo/ui/elements/board/board-cell/board_background.dart';
import 'package:ludo/ui/elements/board/board-cell/token-home/home_container_list.dart';

class StaticGameBoard extends StatelessWidget {
  final double cellSize;
  final double tokenHomeSize;

  const StaticGameBoard({
    super.key,
    required this.cellSize,
    required this.tokenHomeSize,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ کل اجزای ثابت بورد بازی فقط و فقط یک لایه در حافظه تشکیل می‌دهند
    return RepaintBoundary(
      child: Stack(
        children: [
          const BoardBackground(), // همان جدولی که فرستادی
          ...getColorizeHomeContainerList(cellSize, tokenHomeSize),
          ...getHomeContainerList(cellSize, tokenHomeSize),
        ],
      ),
    );
  }
}