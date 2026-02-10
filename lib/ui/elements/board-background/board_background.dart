import 'package:flutter/material.dart';
import 'package:ludo/ui/elements/board-background/cell_decoration.dart';
import 'center_painter.dart';

class BoardBackground extends StatelessWidget {
  static const int size = 11;

  const BoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Table(
      children: List.generate(size, (row) {
        return TableRow(
          children: List.generate(size, (col) => _cell(row, col)),
        );
      }),
    );
  }

  Widget _cell(int row, int col) {
    return AspectRatio(
      aspectRatio: 1,
      child: isCenterCell(row, col)
          ? CustomPaint(painter: CenterPainter(row, col))
          : Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black26),
                gradient: getColor(row, col),
              ),
            ),
    );
  }
}
