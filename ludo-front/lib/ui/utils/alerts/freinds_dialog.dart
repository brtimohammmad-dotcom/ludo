import 'package:flutter/material.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

void showFriendsPlayDialog(BuildContext context, double boardSize, dynamic handler) {
  final double base = boardSize * 0.85;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: base,
          padding: EdgeInsets.all(base * 0.05),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 1.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: base * 0.12,
                color: const Color(0xFFFFD700),
              ),
              SizedBox(height: base * 0.02),
              Text(
                context.tr('friends level dialog title'),
                style: TextStyle(
                  color: const Color(0xFFFFF8DC),
                  fontSize: base * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: base * 0.015),
              Text(
                context.tr('friends level dialog text'),
                style: TextStyle(
                  color: const Color(0xFFD4AF37),
                  fontSize: base * 0.032,
                ),
              ),
              SizedBox(height: base * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    context: context,
                    label: context.tr('2 Players'),
                    icon: Icons.person_outline_rounded,
                    base: base,
                    onTap: () {
                      Navigator.pop(context);
                      handler.handleGameSearch(
                        numberOfPlayers: 2,
                        gameType: GameType.friendly,
                        gameLevel: GameLevel.free,
                        boardSize: boardSize,
                      );
                    },
                  ),
                  _buildDialogButton(
                    context: context,
                    label: context.tr('4 Players'),
                    icon: Icons.people_outline_rounded,
                    base: base,
                    onTap: () {
                      Navigator.pop(context);
                      handler.handleGameSearch(
                        numberOfPlayers: 4,
                        gameType: GameType.friendly,
                        gameLevel: GameLevel.free,
                        boardSize: boardSize,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: base * 0.04),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  context.tr('Close'),
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: base * 0.035,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildDialogButton({
  required BuildContext context,
  required String label,
  required IconData icon,
  required double base,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: base * 0.38,
      padding: EdgeInsets.symmetric(vertical: base * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: base * 0.08),
          SizedBox(height: base * 0.02),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontWeight: FontWeight.bold,
              fontSize: base * 0.035,
            ),
          ),
          SizedBox(height: base * 0.01),
          Text(
            context.tr('Free'),
            style: TextStyle(
              color: const Color(0xFF4ADE80),
              fontWeight: FontWeight.w600,
              fontSize: base * 0.028,
            ),
          ),
        ],
      ),
    ),
  );
}