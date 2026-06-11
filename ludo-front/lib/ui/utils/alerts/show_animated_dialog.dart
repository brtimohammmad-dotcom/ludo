import 'package:flutter/material.dart';

Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  final size = MediaQuery.of(context).size;
  final boardSize = size.width < size.height ? size.width : size.height * 0.86;

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (ctx, animation, _, dialogChild) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: dialogChild,
        ),
      );
    },
    pageBuilder: (dialogContext, primaryAnimation, secondaryAnimation) =>
        AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: boardSize * 0.5,
            padding: EdgeInsets.all(boardSize * 0.02),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.blueGrey, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(boardSize * 0.09),
            ),
            child: child,
          ),
        ),
  );
}
