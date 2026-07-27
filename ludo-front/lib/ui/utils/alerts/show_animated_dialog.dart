import 'package:flutter/material.dart';

Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  RouteSettings? routeSettings,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: '',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    routeSettings: routeSettings,
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
          content: child,
        ),
  );
}