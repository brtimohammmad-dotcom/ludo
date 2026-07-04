import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class InAnotherGameEvent implements GameEvent {
  @override
  void execute(GameController controller) {
    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.showAlert(
        "You are already in another game!",
        () {},
      );
    }
  }
}
