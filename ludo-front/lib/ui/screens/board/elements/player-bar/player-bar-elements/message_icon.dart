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
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            color: const Color(0xFFFFD700),
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}