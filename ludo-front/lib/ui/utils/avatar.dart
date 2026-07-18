import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? url;
  final double size;
  final Color borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    required this.url,
    required this.size,
    this.borderColor = Colors.amber,
    this.borderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.4),
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: url != null
            ? Image.network(
          url!,
          fit: BoxFit.cover,
          cacheWidth: (size * 2).toInt(),
          cacheHeight: (size * 2).toInt(),
          errorBuilder: (_, _, _) => _buildDefaultAvatar(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: size * 0.5,
                height: size * 0.5,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                ),
              ),
            );
          },
        )
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color(0xFF22222E),
      child: Icon(
        Icons.person_rounded,
        color: borderColor.withValues(alpha: 0.7),
        size: size * 0.6,
      ),
    );
  }
}