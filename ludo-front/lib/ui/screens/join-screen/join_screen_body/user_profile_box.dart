import 'package:flutter/material.dart';
import 'package:ludo/ui/utils/avatar.dart';

class UserProfileBox extends StatelessWidget {
  final dynamic player;
  final double boardSize;

  const UserProfileBox({
    super.key,
    required this.player,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    final boxHeight = (boardSize * 0.11).clamp(40.0, 52.0);
    final avatarSize = boxHeight * 0.75;
    final String name = player?.username ?? "Player";
    final String? avatarUrl = player?.avatarUrl;

    return Container(
      height: boxHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // فلت و هماهنگ با بقیه بخش‌ها
        borderRadius: BorderRadius.circular(boxHeight / 2),
        border: Border.all(
          color: Colors.amber,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            url: avatarUrl,
            size: avatarSize,
            borderColor: Colors.amber,
            borderWidth: 1.0,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}