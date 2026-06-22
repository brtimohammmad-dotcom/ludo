import 'package:flutter/material.dart';

class StartGameButton extends StatelessWidget {
  final int numberOfPlayers;
  final VoidCallback onPressed;

  const StartGameButton({
    super.key,
    required this.numberOfPlayers,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // amber برای دکمه‌های دوستان (-1, -2, -4) و green برای بازی‌های عمومی
    final isAmber = numberOfPlayers < 0;
    final isWide = numberOfPlayers == -1;

    String label = "";
    if (numberOfPlayers == -1) {
      label = "Friends";
    } else if (numberOfPlayers == 2 || numberOfPlayers == -2) {
      label = "2 Players";
    } else {
      label = "4 Players";
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isWide ? 250 : 120, 50),
        elevation: 3,
        backgroundColor: isAmber ? Colors.amber : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}