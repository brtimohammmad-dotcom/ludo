// lib/ui/screens/join-screen/join_screen_body/user_profile_box.dart
import 'package:flutter/material.dart';

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
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(boxHeight / 2),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: (boxHeight * 0.32).clamp(12.0, 15.0),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          _buildAvatar(avatarUrl, avatarSize),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, double size) {
    // اگر آدرس آواتار برای تلگرام بود، آن را از پروکسی سرور خودت عبور بده
    final String? safeUrl = (url != null && url.startsWith('https://api.telegram.org'))
        ? "https://ludo-tecb.onrender.com/proxy-avatar?url=${Uri.encodeComponent(url)}"
        : url;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: safeUrl != null && safeUrl.isNotEmpty
            ? Image.network(
          safeUrl,
          fit: BoxFit.cover,
          headers: const {
            'Accept': 'image/*',
          },
          errorBuilder: (_, _, _) => _buildDefaultAvatar(size),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: const CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
              ),
            );
          },
        )
            : _buildDefaultAvatar(size),
      ),
    );
  }

  Widget _buildDefaultAvatar(double size) {
    return Container(
      color: const Color(0xFF22222E),
      child: Icon(
        Icons.person_rounded,
        color: Colors.amber.withValues(alpha: 0.7),
        size: size * 0.6,
      ),
    );
  }
}