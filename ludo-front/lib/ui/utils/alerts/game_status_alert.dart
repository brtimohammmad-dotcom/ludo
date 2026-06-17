import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';

class WaitingForPlayersAlert extends StatefulWidget {
  const WaitingForPlayersAlert({
    super.key,
    required this.gameController,
    required this.onExit,
  });

  final GameController gameController;
  final VoidCallback onExit;

  @override
  State<WaitingForPlayersAlert> createState() =>
      _WaitingForPlayersAlertState();
}

class _WaitingForPlayersAlertState extends State<WaitingForPlayersAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final boardSize =
    size.width < size.height ? size.width : size.height * 0.86;

    final state = widget.gameController.gameState?.serverState;

    final gameMode = state?.numberOfPlayers ?? 2;
    final requiredPlayers =
    gameMode < 0 ? -gameMode : (gameMode == -1 ? 2 : gameMode);

    final currentPlayers = state?.players.length ?? 0;

    // 🎯 لینک دعوت که از بک‌اند میاد (همونی که گفتی درسته)
    final String? invitationLink = state?.invitationLink;

    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⏳ loading animation
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: boardSize * 0.18,
                height: boardSize * 0.18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [Colors.transparent, Colors.white],
                  ),
                ),
              ),
            ),

            SizedBox(height: boardSize * 0.03),

            Text(
              'Waiting for Players',
              style: TextStyle(
                fontSize: boardSize * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            SizedBox(height: boardSize * 0.02),

            Text(
              "$currentPlayers / $requiredPlayers Joined",
              style: TextStyle(
                fontSize: boardSize * 0.04,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: boardSize * 0.05),

            // 🔥 SHARE BUTTON
            if (invitationLink != null)
              ElevatedButton.icon(
                onPressed: () {
                  final telegramShareUrl =
                      "https://t.me/share/url?url=${Uri.encodeComponent(invitationLink)}";

                  TelegramWebApp.instance.openLink(telegramShareUrl);
                },
                icon: const Icon(Icons.share),
                label: const Text("Share Invite"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: boardSize * 0.08,
                    vertical: boardSize * 0.03,
                  ),
                ),
              ),

            SizedBox(height: boardSize * 0.03),

            // ❌ Cancel button
            ElevatedButton(
              onPressed: widget.onExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}