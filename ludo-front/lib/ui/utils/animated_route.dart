
import 'package:flutter/material.dart';

enum RouteAnimation { fade, scale, slideFromBottom, slideFromRight }

PageRouteBuilder<T> animatedRoute<T>({
  required Widget page,
  RouteAnimation type = RouteAnimation.fade,
  Duration duration = const Duration(milliseconds: 250),
}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      switch (type) {
        case RouteAnimation.fade:
          return FadeTransition(opacity: curved, child: child);

        case RouteAnimation.scale:
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
              child: child,
            ),
          );

        case RouteAnimation.slideFromBottom:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );

        case RouteAnimation.slideFromRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
      }
    },
  );
}