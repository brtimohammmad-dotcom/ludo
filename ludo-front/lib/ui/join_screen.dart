import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
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

    // ۱. ساخت کنترلر فقط و فقط برای یک‌بار
    gameController = GameController();

    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      TelegramWebApp.instance.expand();
    }

    // ۲. استارت اتصال اولیه سوکت
    gameController.connectToGame();

    // ۳. لیسنر دیسکانکت تلگرام
    gameController.gameRepository.dataSource.onDisconnectCallback = () {
      if (mounted && TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert(
          'ارتباط با سرور قطع شد. در حال تلاش برای اتصال مجدد...',
        );
      }
    };
  }

  // 🚨 اصلاح اول: حتماً متد dispose را اضافه کن تا در صورت نابودی صفحه، سوکت باز نماند
  @override
  void dispose() {
    gameController.deleteGameState(); // پاکسازی کامل وضعیت و بستن سوکت قدیمی
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        return gameController.gameState?.livePlayer == null
            ? Scaffold( // اضافه کردن Scaffold برای رندر درست لودینگ در صفحات مختلف
          body: Center(
            child: Lottie.asset(
              "assets/lotties/Happy girl.json",
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              frameRate: FrameRate(30),
              renderCache: RenderCache.raster,
            ),
          ),
        )
            : Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(120, 50),
        elevation: 3,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: () {
        gameController.startGame(gameMode: gameMode);

        // 🚨 نکته معماری: چون JoinScreen در پس‌زمینه زنده می‌ماند،
        // در کالبک دکمه خروج (onHomePressed) باید کل استک را پاک کنیم که جلوتر توضیح داده‌ام.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Board(gameController: gameController),
          ),
        );
      },
      child: Text(
        gameMode == 2 ? "2 players" : "4 players",
        style: const TextStyle(color: Colors.white, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}