import 'package:flutter/material.dart';
import 'package:ludo/ui/join_screen.dart';
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
  State<WaitingForPlayersAlert> createState() => _WaitingForPlayersAlertState();
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
    final boardSize = size.width < size.height
        ? size.width
        : size.height * 0.86;

    final state = widget.gameController.gameState?.serverState;
    final numberOfPlayers = state?.numberOfPlayers ?? 2;
    final requiredPlayers = numberOfPlayers < 0
        ? -numberOfPlayers
        : (numberOfPlayers == -1 ? 2 : numberOfPlayers);

    return ListenableBuilder(
      listenable: widget.gameController,
      builder: (context, child) {
        final state = widget.gameController.gameState?.serverState;
        final currentPlayers = state?.players.length ?? 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⏳ آیکون چرخان وضعیت انتظار
            RotationTransition(
              turns: _rotationController,
              child: Container(
                width: boardSize * 0.18,
                height: boardSize * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: boardSize * 0.012,
                  ),
                  gradient: const SweepGradient(
                    colors: [Colors.transparent, Colors.white],
                  ),
                ),
              ),
            ),

            SizedBox(height: boardSize * 0.025),

            // عنوان
            Text(
              'Waiting for Players',
              style: TextStyle(
                fontSize: boardSize * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: boardSize * 0.02),

            // نمایش گرافیکی وضعیت جایگاه صندلی بازیکنان
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: requiredPlayers == 2
                    ? boardSize * 0.06
                    : boardSize * 0.03,
                vertical: boardSize * 0.025,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(boardSize * 0.06),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(requiredPlayers, (index) {
                  final isJoined = index < currentPlayers;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: requiredPlayers == 2
                          ? boardSize * 0.015
                          : boardSize * 0.005,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      width: requiredPlayers == 2
                          ? boardSize * 0.09
                          : boardSize * 0.08,
                      height: requiredPlayers == 2
                          ? boardSize * 0.09
                          : boardSize * 0.08,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isJoined
                            ? Colors.green.shade600
                            : Colors.grey.shade300,
                      ),
                      child: Icon(
                        isJoined ? Icons.person : Icons.person_outline,
                        color: isJoined ? Colors.white : Colors.grey.shade500,
                        size: boardSize * 0.05,
                      ),
                    ),
                  );
                }),
              ),
            ),

            SizedBox(height: boardSize * 0.02),

            // متن تعداد عددی وضعیت اعضا
            Text(
              '$currentPlayers / $requiredPlayers Joined',
              style: TextStyle(
                fontSize: boardSize * 0.04,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: boardSize * 0.04),

            if (state!.mode==GameMode.friendly) ...[
              // دکمه طلایی اشتراک‌گذاری رسمی و نیتیو در محیط تلگرام
              ElevatedButton.icon(
                onPressed: () {
                  final gameId = state.gameId;

                  TelegramWebApp.instance.switchInlineQuery("game_$gameId", [
                    ChatType.groups,
                    ChatType.users,
                    ChatType.channels,
                  ]);
                },
                icon: const Icon(Icons.share, color: Colors.black87),
                label: const Text('Share Invite Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(
                    horizontal: boardSize * 0.08,
                    vertical: boardSize * 0.03,
                  ),
                  textStyle: TextStyle(
                    fontSize: boardSize * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(boardSize * 0.04),
                  ),
                ),
              ),

              SizedBox(height: boardSize * 0.03),
            ],

            // دکمه لغو یا خروج از اتاق بازی
            ElevatedButton(
              onPressed: widget.onExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: boardSize * 0.09,
                  vertical: boardSize * 0.025,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(boardSize * 0.04),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: boardSize * 0.03,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
