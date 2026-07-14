
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/emoji-box-controller/emoji_box_notifier.dart';

class MessageIcon extends ConsumerWidget {
  const MessageIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.blueGrey, // یا هر رنگی که به تم بازی بیاید
        padding: const EdgeInsets.all(12),
      ),
      onPressed: () {
        ref.read(emojiBoxProvider.notifier).toggle();
      },
    );
  }
}