import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class ReconnectingAlert extends StatelessWidget {
  const ReconnectingAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final boardSize = (screenWidth < screenHeight ? screenWidth : screenHeight * 0.86);
    final double base = boardSize * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.symmetric(
          horizontal: base * 0.06,
          vertical: base * 0.08,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.beat(
              color: Colors.amberAccent,
              size: base * 0.15,
            ),
            SizedBox(height: base * 0.05),
            Text(
              context.tr('reconnecting alert title'),
              style: TextStyle(
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: base * 0.02),
            Text(
              context.tr('reconnecting alert text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: base * 0.032,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}