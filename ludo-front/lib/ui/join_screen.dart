import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/alerts/alert_background.dart';
import 'package:ludo/ui/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/elements/board/board.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final GameController gameController;

  @override
  void initState() {
    super.initState();

    // ساخت کنترلر فقط یک‌بار
    gameController = GameController();

    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      TelegramWebApp.instance.expand();
    }

    // اتصال سوکت فقط یک‌بار
    gameController.connectToGame();

    // هندل قطع اتصال
    gameController.gameRepository.dataSource.onDisconnectCallback = () {
      if (mounted && TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert(
          'ارتباط با سرور قطع شد. در حال تلاش برای اتصال مجدد...',
        );
      }
    };
    // --- RECONNECTION FAILED ---
    gameController.onReconnectionFailed = () {
      if (!mounted) return;

      _showDialog(
        AlertBackground(
          alert: ReconnectingFailedAlert(
            onHomePressed: () async {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }

              gameController.deleteGameState();

              await Future.delayed(const Duration(milliseconds: 50));

              if (mounted) {
                gameController.connectToGame();
              }
            },
            textButton: "اتصال مجدد",
          ),
        ),
      );
    };
  }

  void _showDialog(Widget dialog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => dialog,
    );
  }

  @override
  void dispose() {
    // پاکسازی کامل سوکت و وضعیت
    gameController.deleteGameState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        final player = gameController.gameState?.livePlayer;

        return Scaffold(
          body: player == null
              ? Center(
                  child: Lottie.asset(
                    "assets/lotties/Happy girl.json",
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    frameRate: FrameRate(30),
                    renderCache: RenderCache.raster,
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade500,
                        Colors.blueGrey,
                        Colors.blueGrey,
                        Colors.blueGrey.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          "assets/lotties/Happy Dice.json",
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StartGameButton(
                              gameController: gameController,
                              gameMode: 2,
                            ),
                            const SizedBox(width: 20),
                            StartGameButton(
                              gameController: gameController,
                              gameMode: 4,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class StartGameButton extends StatelessWidget {
  const StartGameButton({
    super.key,
    required this.gameController,
    required this.gameMode,
  });

  final int gameMode;
  final GameController gameController;

  bool get isSocketConnected {
    return gameController.gameRepository.dataSource.isConnected;
  }

  @override
  Widget build(BuildContext context) {
    final connected = isSocketConnected;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(120, 50),
        elevation: 3,
        backgroundColor: connected ? Colors.green : Colors.grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: connected
          ? () {
        gameController.startGame(gameMode: gameMode);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Board(gameController: gameController),
          ),
        );
      }
          : () {
        if (TelegramWebApp.instance.isSupported) {
          TelegramWebApp.instance.showAlert(
            "اتصال به سرور برقرار نیست. لطفاً چند لحظه صبر کنید...",
          );
        }
      },
      child: Text(
        gameMode == 2 ? "2 players" : "4 players",
        style: const TextStyle(color: Colors.white, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}

