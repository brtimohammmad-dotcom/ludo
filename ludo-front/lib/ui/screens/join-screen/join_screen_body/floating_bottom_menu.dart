import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class FloatingBottomMenu extends StatelessWidget {
  final double boardSize;
  final VoidCallback onFriendsTap;
  final VoidCallback onLeaderboardTap;
  final VoidCallback onShopTap;

  const FloatingBottomMenu({
    super.key,
    required this.boardSize,
    required this.onFriendsTap,
    required this.onLeaderboardTap,
    required this.onShopTap,
  });

  @override
  Widget build(BuildContext context) {
    final menuHeight = boardSize * 0.18;
    final innerBarHeight = boardSize * 0.145;
    final centerButtonSize = boardSize * 0.165;

    return Container(
      margin: EdgeInsets.only(
        bottom: boardSize * 0.04,
        left: boardSize * 0.05,
        right: boardSize * 0.05,
      ),
      height: menuHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: innerBarHeight,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(boardSize * 0.04),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                width: 1.8,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: StandardMenuItem(
                    icon: Icons.people_alt_rounded,
                    label: context.tr('friends'),
                    boardSize: boardSize,
                    onTap: onFriendsTap,
                  ),
                ),
                SizedBox(width: centerButtonSize * 1.1),
                Expanded(
                  child: StandardMenuItem(
                    icon: Icons.storefront_rounded,
                    label: context.tr('shop'),
                    boardSize: boardSize,
                    onTap: onShopTap,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: boardSize * 0.01,
            child: HighlightedCenterItem(
              icon: Icons.emoji_events_rounded,
              label: context.tr('Leaderboard'),
              buttonSize: centerButtonSize,
              boardSize: boardSize,
              onTap: onLeaderboardTap,
            ),
          ),
        ],
      ),
    );
  }
}

class StandardMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double boardSize;
  final VoidCallback onTap;

  const StandardMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.boardSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(boardSize * 0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFFF8DC), size: boardSize * 0.055),
          SizedBox(height: boardSize * 0.008),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontSize: boardSize * 0.026,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightedCenterItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final double buttonSize;
  final double boardSize;
  final VoidCallback onTap;

  const HighlightedCenterItem({
    super.key,
    required this.icon,
    required this.label,
    required this.buttonSize,
    required this.boardSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref
        .watch(globalLoadingProvider)
        .contains('leader_board_loading');
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5A2B), Color(0xFF5C3613)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: const Color(0xFFFFD700), width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: isLoading
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(
                color: Color(0xFFFFD700),
                strokeWidth: 2,
              ),
            )
                : Icon(
              icon,
              color: const Color(0xFFFFD700),
              size: buttonSize * 0.5,
            ),
          ),
          SizedBox(height: boardSize * 0.008),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontSize: boardSize * 0.028,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}