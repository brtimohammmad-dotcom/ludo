import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:telegram_web_app/telegram_web_app.dart';

class Config {
  static Timer? _timer;
  static bool? _isConnected;
  static int reConnectCounter = 0;

  static void startConnectionCheck(
    Function(bool connected, int numberOfReconnecting) onChanged,
  ) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        final response = await http.get(
          Uri.parse('https://ludo-backend-8ihb.onrender.com/health'),
        );

        _isConnected = response.statusCode == 200;

        if (_isConnected == false) {
          if (TelegramWebApp.instance.isSupported) {
            TelegramWebApp.instance.showAlert('در حال اتصال به اینترنت');
          }
          reConnectCounter++;
          onChanged(_isConnected!, reConnectCounter);
        } else {
          reConnectCounter = 0;
          onChanged(true, reConnectCounter);
        }
      } catch (e) {
        debugPrint("ERROR: $e");

        if (_isConnected == true) {
          debugPrint("DISCONNECTED");
          _isConnected = false;

          TelegramWebApp.instance.showAlert('در حال اتصال به اینترنت');

        }
        reConnectCounter++;
        onChanged(false, reConnectCounter);
      }
    });
  }

  static void stopConnectionCheck() {
    _timer?.cancel();
    _timer = null;
    reConnectCounter = 0;
    _isConnected = null;
    debugPrint("⏱️ Connection check timer stopped.");
  }

  static String get serverUrl {
    // اگر روی وب نیست (موبایل یا دسکتاپ)
    if (!kIsWeb) {
      return 'http://localhost:3000';
    }

    // ✅ استفاده از Uri.base بدون هیچ پکیج اضافی
    try {
      final currentOrigin = Uri.base.origin;
      final currentHost = Uri.base.host;

      debugPrint('🌍 Current origin: $currentOrigin');
      debugPrint('🌍 Current host: $currentHost');

      // اگر روی رندر اجرا می‌شود
      if (currentOrigin.contains('onrender.com') ||
          currentHost.contains('onrender.com')) {
        return 'https://ludo-backend-8ihb.onrender.com';
      }

      // اگر روی لوکال هاست است
      if (currentOrigin.contains('localhost') ||
          currentOrigin.contains('127.0.0.1') ||
          currentHost.contains('localhost') ||
          currentHost.contains('127.0.0.1')) {
        return 'http://localhost:3000';
      }
    } catch (e) {
      debugPrint('Error detecting environment: $e');
    }

    // پیش‌فرض
    return 'http://localhost:3000';
  }

  // متد کمکی برای دیباگ
  static void printEnvironmentInfo() {
    if (kIsWeb) {
      debugPrint('📱 Platform: Web');
      debugPrint('📍 Origin: ${Uri.base.origin}');
      debugPrint('📍 Host: ${Uri.base.host}');
      debugPrint('📍 Protocol: ${Uri.base.scheme}');
      debugPrint('🔌 Server URL: $serverUrl');
    } else {
      debugPrint('📱 Platform: Mobile/Desktop');
      debugPrint('🔌 Server URL: $serverUrl');
    }
  }
}
