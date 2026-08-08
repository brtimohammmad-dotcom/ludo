import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class InsufficientCoinsAlert extends StatelessWidget {
  final int requiredCoins;
  final int currentCoins;

  const InsufficientCoinsAlert({
    super.key,
    required this.requiredCoins,
    required this.currentCoins,
  });

  @override
  Widget build(BuildContext context) {
    final double base = MediaQuery.of(context).size.width * 0.85;

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
            color: const Color(0xFFFFD700),
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
            // آیکون سکه افکت‌دار
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: base * 0.16,
                  height: base * 0.16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  ),
                ),
                 Icon(
                  Icons.monetization_on,
                  size: base * 0.12,
                  color: Color(0xFFFFD700),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(
                    Icons.close,
                    size: base * 0.045,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: base * 0.04),
            Text(
              context.tr('insufficient coins title'),
              style: TextStyle(
                color: const Color(0xFFFFD700),
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: base * 0.03),
            Text(
              "${context.tr('You need')} ${context.num(requiredCoins)} ${context.tr('insufficient coins text')} ${context.num(currentCoins)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFD4AF37),
                fontSize: base * 0.035,
                height: 1.4,
              ),
            ),
            SizedBox(height: base * 0.06),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.03),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    context.tr('OK'),
                    style: TextStyle(
                      color: const Color(0xFFFFF8DC),
                      fontSize: base * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}