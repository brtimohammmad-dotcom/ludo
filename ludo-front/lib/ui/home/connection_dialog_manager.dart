import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class ConnectionDialogManager {
  // نام‌های اختصاصی برای routeهای مربوط به اتصال
  static const String _reconnectingRouteName = '/reconnecting_alert';
  static const String _reconnectingFailedRouteName = '/reconnecting_failed_alert';

  /// 🟢 بستن هوشمند: فقط اگر دیالوگ فعلی مربوط به شکست اتصال باشد
// فقط و فقط اگر آلرت فعلی ReconnectingFailedAlert باشه می‌بنددش
  static void closeFailedDialogOnly(BuildContext context) {
    final currentRoute = ModalRoute.of(context);

    if (currentRoute?.settings.name == _reconnectingFailedRouteName) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  /// 🟢 بستن هر نوع دیالوگ مربوط به شبکه (Reconnecting یا Failed)
  static void closeConnectionDialogs(BuildContext context) {
    final currentRouteName = ModalRoute.of(context)?.settings.name;
    debugPrint('currentRouteName: ');
    debugPrint(currentRouteName);
    if (currentRouteName == _reconnectingFailedRouteName ||
        currentRouteName == _reconnectingRouteName) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    }
  }

  static void showReconnecting(BuildContext context) {
    closeConnectionDialogs(context);

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: _reconnectingRouteName), // 👈 تعیین نام route
      child: const ReconnectingAlert(),
    );
  }

  static void showReconnectingFailed(BuildContext context, WidgetRef ref) {
    closeConnectionDialogs(context);
    final controller = ref.read(gameControllerProvider.notifier);

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      routeSettings: const RouteSettings(name: _reconnectingFailedRouteName), // 👈 تعیین نام route
      child: ReconnectingFailedAlert(
        onReconnectPressed: () {
          showReconnecting(context);

          controller.updateState(
            controller.currentGameState?.copyWith(
              connectionStatus: ConnectionStatus.reconnecting,
            ),
          );
          controller.resumeReconnection();
        },
      ),
    );
  }
}