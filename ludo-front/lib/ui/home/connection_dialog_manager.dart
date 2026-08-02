import 'package:flutter/material.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_alert.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class ConnectionDialogManager {
  static bool _isDialogShowing = false;

  /// 🟢 بستن امن تمام دیالوگ‌های باز شبکه
  static void closeConnectionDialogs(BuildContext context) {
    if (_isDialogShowing) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _isDialogShowing = false;
    }
  }

  /// 🟡 نمایش آلرت در حال اتصال مجدد
  static void showReconnecting(BuildContext context) {
    if (_isDialogShowing) {
      closeConnectionDialogs(context);
    }
    _isDialogShowing = true;

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: const ReconnectingAlert(),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  /// 🔴 نمایش آلرت خطا در اتصال (با اکشن سفارشی بدون نیاز مستقیم به ref)
  static void showReconnectingFailed(
      BuildContext context, {
        required VoidCallback onReconnectPressed,
      }) {
    if (_isDialogShowing) {
      closeConnectionDialogs(context);
    }
    _isDialogShowing = true;

    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      child: ReconnectingFailedAlert(
        onReconnectPressed: () {
          // ۱. ابتدا دیالوگ فعلی را ببند
          closeConnectionDialogs(context);

          // ۲. سپس اکشن ری‌کانکت را اجرا کن
          onReconnectPressed();
        },
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}