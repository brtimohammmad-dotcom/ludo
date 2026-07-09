import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class DisconnectEvent implements GameEvent {
  bool _isDisconnectAlertShow = false;

  @override
  void execute(GameController controller) {
    if (_isDisconnectAlertShow) return;
    if (TelegramWebApp.instance.isSupported) {
      controller.clearAllLoadings();
      _isDisconnectAlertShow = true;
      TelegramWebApp.instance.showAlert(
        'Connection lost. Reconnecting...',
        () => _isDisconnectAlertShow = false,
      );
    }
  }
}
