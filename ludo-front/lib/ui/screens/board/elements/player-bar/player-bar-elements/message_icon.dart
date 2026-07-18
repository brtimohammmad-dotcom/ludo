import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/emoji-box-controller/emoji_box_notifier.dart';

class MessageIcon extends ConsumerWidget {
  final double boardSize;
  const MessageIcon({required this.boardSize, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = boardSize * 0.055;
    return GestureDetector(
      onTap: () => ref.read(emojiBoxProvider.notifier).toggle(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF2A1B3D), // رنگ بنفش مات فلت
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFA855F7), width: 1.0),
        ),
        child: Center(
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFE9D5FF),
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}