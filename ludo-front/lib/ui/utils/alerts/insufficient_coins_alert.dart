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
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
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
            // آیکون سکه افکت‌دار
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: base * 0.16,
                  height: base * 0.16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.1),
                  ),
                ),
                Icon(
                  Icons.monetization_on,
                  size: base * 0.12,
                  color: Colors.amberAccent,
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
                color: Colors.amberAccent,
                fontSize: base * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: base * 0.03),
            Text(
              "${context.tr('You need')} ${context.num(requiredCoins)} ${context.tr('insufficient coins text')} ${context.num(currentCoins)}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
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
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    context.tr('OK'),
                    style: TextStyle(
                      color: Colors.white,
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
