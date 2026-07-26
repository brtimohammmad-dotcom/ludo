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
    final String name = player?.username ?? "Player";
    final String? avatarUrl = player?.avatarUrl;

    return Container(
      height: 38,
      padding: const EdgeInsets.only(left: 4, right: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(
            url: avatarUrl,
            size: 28,
            borderColor: const Color(0xFFFFB703),
            borderWidth: 1.5,
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}