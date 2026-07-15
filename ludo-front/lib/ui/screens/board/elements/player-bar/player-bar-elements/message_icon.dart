import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/emoji-box-controller/emoji_box_notifier.dart';

class MessageIcon extends ConsumerWidget {
  final double boardSize;
  const MessageIcon({
    required this.boardSize,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = boardSize * 0.055;

    return GestureDetector(
      onTap: () {
        ref.read(emojiBoxProvider.notifier).toggle();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          // 🌌 شیشه‌ای بنفش ملایم هماهنگ با تم نئون و چت
          color: const Color(0x229C27B0),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0x8A9C27B0), // مرز نئونی بنفش
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x229C27B0),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFE040FB), // صورتی/بنفش درخشان
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}