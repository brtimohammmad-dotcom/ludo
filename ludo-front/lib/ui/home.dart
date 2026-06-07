import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/join_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class Home extends StatefulWidget {
  final GameController gameController;

  const Home({super.key, required this.gameController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.gameController.connectToGame();
    widget.gameController.gameRepository.dataSource.socket!.onDisconnect((
      _,
    ) async {
      debugPrint("🔴 Socket Disconnected! Starting health check...");

      // نمایش پاپ‌آپ یا لودینگ در تلگرام (فقط یک‌بار در لحظه قطعی)
      if (TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert(
          'ارتباط با سرور قطع شد. در حال تلاش برای اتصال مجدد...',
        );
      }

      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => Home(gameController: GameController()),
      //   ),
      //   (route) => false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: ((context, child) {
        debugPrint(widget.gameController.gameState?.livePlayer?.username);
        return widget.gameController.gameState?.livePlayer == null
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
            : Column(
                children: [
                  Expanded(
                    child: JoinScreen(gameController: widget.gameController),
                  ),
                ],
              );
      }),
    );
  }
}
