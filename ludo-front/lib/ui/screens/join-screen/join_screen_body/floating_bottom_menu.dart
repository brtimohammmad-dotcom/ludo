import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';

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
              color: const Color(0xFF1E293B), // رنگ مات فلت بجای نیمه شفاف
              borderRadius: BorderRadius.circular(boardSize * 0.04),
              border: Border.all(
                color: const Color(0xFF334155),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: StandardMenuItem(
                    icon: Icons.people_alt_rounded,
                    label: 'Friends',
                    boardSize: boardSize,
                    onTap: onFriendsTap,
                  ),
                ),
                SizedBox(width: centerButtonSize * 1.1),
                Expanded(
                  child: StandardMenuItem(
                    icon: Icons.storefront_rounded,
                    label: 'Shop',
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
              label: 'Leaderboard',
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
          Icon(icon, color: Colors.white70, size: boardSize * 0.055),
          SizedBox(height: boardSize * 0.008),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: boardSize * 0.026,
              fontWeight: FontWeight.w600,
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
              color: const Color(0xFF0EA5E9), // رنگ فلت آبی روشن نئونی بجای تیره
              border: Border.all(color: const Color(0xFF38BDF8), width: 2.0),
            ),
            child: isLoading
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Icon(
              icon,
              color: Colors.white,
              size: buttonSize * 0.5,
            ),
          ),
          SizedBox(height: boardSize * 0.008),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: boardSize * 0.028,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}