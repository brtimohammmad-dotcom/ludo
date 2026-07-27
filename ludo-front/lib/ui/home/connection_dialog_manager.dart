import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class ConnectionDialogManager {
  // نگهداری context متناظر با دیالوگ‌های باز شده
  static BuildContext? _reconnectingDialogContext;
  static BuildContext? _failedDialogContext;

  /// 🟢 بستن فقط دیالوگ خطای اتصال
  static void closeFailedDialogOnly() {
    if (_failedDialogContext != null && _failedDialogContext!.mounted) {
      if (Navigator.canPop(_failedDialogContext!)) {
        Navigator.of(_failedDialogContext!).pop();
      }
      _failedDialogContext = null;
    }
  }

  /// 🟢 بستن هر دو دیالوگ مربوط به شبکه
  static void closeConnectionDialogs() {
    closeFailedDialogOnly();

    if (_reconnectingDialogContext != null && _reconnectingDialogContext!.mounted) {
      if (Navigator.canPop(_reconnectingDialogContext!)) {
        Navigator.of(_reconnectingDialogContext!).pop();
      }
      _reconnectingDialogContext = null;
    }
  }

  static void showReconnecting(BuildContext context) {
    closeConnectionDialogs();

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: Builder(
        builder: (dialogCtx) {
          _reconnectingDialogContext = dialogCtx;
          return const ReconnectingAlert();
        },
      ),
    );
  }

  static void showReconnectingFailed(BuildContext context, WidgetRef ref) {
    closeConnectionDialogs();
    final controller = ref.read(gameControllerProvider.notifier);

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: Builder(
        builder: (dialogCtx) {
          // ذخیره context اختصاصی خود دیالوگ
          _failedDialogContext = dialogCtx;
          return ReconnectingFailedAlert(
            onReconnectPressed: () {
              showReconnecting(context);

              controller.updateState(
                controller.currentGameState?.copyWith(
                  connectionStatus: ConnectionStatus.reconnecting,
                ),
              );
              controller.resumeReconnection();
            },
          );
        },
      ),
    );
  }
}