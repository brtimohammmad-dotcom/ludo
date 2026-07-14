import 'package:flutter/material.dart';

class PlayerEmojiBubble extends StatelessWidget {
  final String emoji;
  final double cellSize;

  const PlayerEmojiBubble({super.key, required this.emoji, required this.cellSize});

  static const Map<String, String> _emojiMap = {
    'laugh': '😂',
    'angry': '😡',
    'cry': '😢',
    'cool': '😎',
    'shocked': '😮',
    'thumbs_up': '👍',
  };

  @override
  Widget build(BuildContext context) {
    // پیدا کردن کاراکتر ایموجی یا مقدار فال‌بک برای جلوگیری از کرش
    final String displayEmoji = _emojiMap[emoji] ?? '💬';

    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // سرعت باز شدن انیمیشن
        reverseDuration: const Duration(milliseconds: 200), // سرعت بسته شدن و محو شدن
        // افکت جهش (Bounce) برای جذابیت نئونی و بازی مینی‌اپ
        switchInCurve: Curves.bounceOut,
        switchOutCurve: Curves.easeIn,
        // انیمیشن سفارشی ترکیبی (همزمان افکت بزرگ‌نمایی و محوشدگی)
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        // برای اینکه انیمیشن متوجه تغییرات (خالی شدن یا تغییر ایموجی) بشود، نیاز به کاندیشنال با کلید متفاوت داریم
        child: emoji.isEmpty
            ? const SizedBox.shrink(key: ValueKey('emoji_empty'))
            : Container(
          key: ValueKey('emoji_box_$emoji'), // کلید منحصربه‌فرد برای بیدار کردن انیمیشن
          padding:  EdgeInsets.all(cellSize*0.1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cellSize*0.2),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
            ],
            border:  Border.fromBorderSide(
              BorderSide(color: Color(0xFFE0E0E0), width: cellSize*0.02),
            ),
          ),
          child: Center(
            child: Text(
              displayEmoji,
              style: TextStyle(
                fontSize: cellSize * 0.7,
                fontFamilyFallback: const [
                  'Noto Color Emoji',
                  'Apple Color Emoji',
                  'Segoe UI Emoji',
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}