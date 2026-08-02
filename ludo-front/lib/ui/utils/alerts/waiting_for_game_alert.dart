import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class WaitingForGameAlert extends StatelessWidget {
  final double boardSize;

  const WaitingForGameAlert({required this.boardSize, super.key});

  @override
  Widget build(BuildContext context) {
    final double base = boardSize * 0.85;
    const accentColor = Colors.amberAccent;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: base,
            padding: EdgeInsets.symmetric(
              vertical: base * 0.08,
              horizontal: base * 0.06,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: LoadingAnimationWidget.halfTriangleDot(
                    color: accentColor,
                    size: base * 0.16,
                  ),
                ),
                SizedBox(height: base * 0.05),
                Text(
                  context.tr('waiting for game alert title'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: base * 0.048,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: base * 0.02),
                Text(
                  context.tr('waiting for game alert text'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: base * 0.032,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}