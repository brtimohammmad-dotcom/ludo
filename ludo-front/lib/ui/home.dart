import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/config_service.dart';
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
    widget.gameController.gameRepository.dataSource.socket!.onDisconnect((_) {
      debugPrint("🔴 Socket Disconnected! Starting health check...");

      // نمایش پاپ‌آپ یا لودینگ در تلگرام (فقط یک‌بار در لحظه قطعی)
      if (TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert(
          'ارتباط با سرور قطع شد. در حال تلاش برای اتصال مجدد...',
        );
      }

      // شروع پینگ زدن برای سنجش وضعیت اینترنت کاربر و سرور
      Config.startConnectionCheck((hasInternet, numberOfReconnects) async {
        debugPrint("Retry #$numberOfReconnects - Internet: $hasInternet");

        // اگر بعد از ۱۲ بار تلاش (حدود ۱ دقیقه) سوکت وصل نشد
        if (numberOfReconnects >= 4) {
          Config.stopConnectionCheck();
          await widget.gameController.dispose();

          if (!mounted) return;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JoinScreen(gameController: GameController()),
            ),
            (route) => false,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    // اگر کاربر خودش هم دستی صفحه را بست، تایمر حتماً متوقف شود
    Config.stopConnectionCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: ((context, child) {
        return widget.gameController.livePlayer == null
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
