import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class ReconnectingFailedAlert extends StatelessWidget {
  final VoidCallback onReconnectPressed;
  const ReconnectingFailedAlert({super.key, required this.onReconnectPressed});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final maxAvailableWidth = screenWidth;
    final maxAvailableHeight = screenHeight;
    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);

    final double base = boardSize * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.06),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.redAccent.withValues(alpha: 0.8),
            width: 1.8,
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
            Icon(
              Icons.signal_wifi_connected_no_internet_4_outlined,
              size: base * 0.15,
              color: Colors.redAccent.shade400,
            ),
            SizedBox(height: base * 0.04),

            Text(
              context.tr('reconnecting failed alert title'),
              style: TextStyle(
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFF8DC),
              ),
            ),
            SizedBox(height: base * 0.02),

            Text(
              context.tr('reconnecting failed alert text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: base * 0.032,
                color: const Color(0xFFD4AF37),
                height: 1.4,
              ),
            ),
            SizedBox(height: base * 0.06),

            GestureDetector(
              onTap: onReconnectPressed,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.03),
                  border: Border.all(color: const Color(0xFFFFD700)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: const Color(0xFFFFF8DC),
                        size: base * 0.045,
                      ),
                      SizedBox(width: base * 0.02),
                      Text(
                        context.tr('Reconnect'),
                        style: TextStyle(
                          color: const Color(0xFFFFF8DC),
                          fontSize: base * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}