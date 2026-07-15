import 'package:flutter/material.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';

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
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.5),
              width: 1.5,
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
                color: Colors.amberAccent,
              ),
              SizedBox(height: base * 0.02),
              Text(
                'Play with Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: base * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: base * 0.015),
              Text(
                'Choose your game mode:',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: base * 0.032,
                ),
              ),
              SizedBox(height: base * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    context: context,
                    label: '2 Players',
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
                    label: '4 Players',
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
                  "Cancel",
                  style: TextStyle(
                    color: Colors.grey.shade400,
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
        color: const Color(0xFF334155), // رنگ متناسب با تم تیره
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
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
          Icon(icon, color: Colors.amberAccent, size: base * 0.08),
          SizedBox(height: base * 0.02),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: base * 0.035,
            ),
          ),
          SizedBox(height: base * 0.01),
          Text(
            'Free',
            style: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w600,
              fontSize: base * 0.028,
            ),
          ),
        ],
      ),
    ),
  );
}