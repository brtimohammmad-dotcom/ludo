import 'package:flutter/material.dart';

void showFriendsPlayDialog(BuildContext context, double boardSize, dynamic handler) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: boardSize * 0.1),
        child: Container(
          padding: EdgeInsets.all(boardSize * 0.05),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E3D), // هماهنگ با تم تیره بازی
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4A6B8C), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Play with Friends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: boardSize * 0.05,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: boardSize * 0.02),
              Text(
                'Choose your game mode:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: boardSize * 0.032,
                ),
              ),
              SizedBox(height: boardSize * 0.05),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // دکمه ۲ نفره دوستانه
                  _buildDialogButton(
                    context: context,
                    label: '2 Players',
                    icon: Icons.person_outline_rounded,
                    color: const Color(0xFF146A7C),
                    boardSize: boardSize,
                    onTap: () {
                      Navigator.pop(context); // بستن دایالوگ
                      handler.handleGameSearch(-2, boardSize); // اجرای متد دوستانه ۲ نفره
                    },
                  ),
                  // دکمه ۴ نفره دوستانه
                  _buildDialogButton(
                    context: context,
                    label: '4 Players',
                    icon: Icons.people_outline_rounded,
                    color: const Color(0xFFC87014),
                    boardSize: boardSize,
                    onTap: () {
                      Navigator.pop(context);
                      handler.handleGameSearch(-4, boardSize); // اجرای متد دوستانه ۴ نفره
                    },
                  ),
                ],
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
  required Color color,
  required double boardSize,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: boardSize * 0.28,
      padding: EdgeInsets.symmetric(vertical: boardSize * 0.03),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 1.5),
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
          Icon(icon, color: Colors.white, size: boardSize * 0.08),
          SizedBox(height: boardSize * 0.015),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: boardSize * 0.032,
            ),
          ),
          SizedBox(height: boardSize * 0.005),
          Text(
            'Free',
            style: TextStyle(
              color: Colors.white60,
              fontSize: boardSize * 0.026,
            ),
          ),
        ],
      ),
    ),
  );
}