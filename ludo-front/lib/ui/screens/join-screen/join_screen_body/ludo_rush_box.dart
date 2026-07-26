import 'package:flutter/material.dart';

class LudoRushBox extends StatelessWidget {
  final double telegramTopPadding;

  const LudoRushBox({super.key, required this.telegramTopPadding});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // 📍 بالاترین نقطه ممکن با احتساب پدینگ تلگرام
      top: MediaQuery.of(context).padding.top + 8 + telegramTopPadding,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            // گریدینت طلایی-نارنجی
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            'Ludo Rush',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black87,
                  offset: Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
