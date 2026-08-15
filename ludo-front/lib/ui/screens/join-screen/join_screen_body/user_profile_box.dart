import 'package:flutter/material.dart';
import 'package:ludo/ui/utils/alerts/player_profile_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
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

    return GestureDetector(
      onTap: () {
        showAnimatedDialog(
          context: context,
          child: PlayerProfileAlert(),
          barrierDismissible: true,
        );
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.only(left: 4, right: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
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
              borderColor: const Color(0xFFFFD700),
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
                  color: Color(0xFFFFF8DC),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
