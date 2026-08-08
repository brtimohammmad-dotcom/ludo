import 'package:flutter/material.dart';

class LudoRushBox extends StatelessWidget {
  final double telegramTopPadding;

  const LudoRushBox({super.key, required this.telegramTopPadding});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 8 + telegramTopPadding;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF5C3613), Color(0xFF2A160C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              const BoxShadow(
                color: Colors.black54,
                offset: Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFFF1A8), Color(0xFFFFD700)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              'LUDO RUSH',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}