import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WaitingForGameAlert extends StatelessWidget {
  final double boardSize;

  const WaitingForGameAlert({required this.boardSize, super.key});

  @override
  Widget build(BuildContext context) {
    // رنگ سبز نئونی تم بازی
    const accentColor = Colors.lightGreenAccent;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          // ایجاد افکت شیشه مات (بلور) روی صفحه پشت دیالوگ
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: boardSize * 0.75,
            padding: EdgeInsets.symmetric(
              vertical: boardSize * 0.06,
              horizontal: boardSize * 0.04,
            ),
            decoration: BoxDecoration(
              // پس‌زمینه تیره و نیمه‌شفاف برای کنتراست عالی با انیمیشن سفید
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              // سایه ملایم نئونی اطراف باکس
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // باکس فقط به اندازه محتوا فضا می‌گیرد
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // لودینگ موجی شما
                LoadingAnimationWidget.waveDots(
                  color: Colors.white,
                  size: boardSize * 0.16,
                ),
                SizedBox(height: boardSize * 0.04),
                // متن اصلاح شده با استایل گیمینگ
                Text(
                  'WAITING FOR game',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: boardSize * 0.04,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 1.2,
                    decoration: TextDecoration.none,
                    // سایه متن برای خوانایی بیشتر و افکت Glow
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: boardSize * 0.02),
                Text(
                  'initial your game...',
                  style: TextStyle(
                    fontSize: boardSize * 0.03,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none,
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