import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    final bool hasValidUrl = url != null && url!.trim().isNotEmpty;

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
        child: hasValidUrl
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,

                // لودینگ در حال دریافت تصویر
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: size * 0.4,
                    height: size * 0.4,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(borderColor),
                    ),
                  ),
                ),
                // در صورت بروز خطا در دانلود
                errorWidget: (context, url, error) => _buildDefaultAvatar(),
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
