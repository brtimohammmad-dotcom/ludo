import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;
import 'package:telegram_web_app/telegram_web_app.dart';

class Config {
  static Timer? _timer;
  static bool? _isConnected;

  static void startConnectionCheck(Function(bool connected) onChanged) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final response = await http.get(
          Uri.parse('https://ludo-backend-8ihb.onrender.com/health'),
        );

        _isConnected = response.statusCode == 200;

        if (_isConnected == false) {
          if (TelegramWebApp.instance.isSupported) {
            TelegramWebApp.instance.showAlert('در حال اتصال به اینترنت');
          }
          onChanged(_isConnected!);
        }
      } catch (e) {
        print("ERROR: $e");

        if (_isConnected == true) {
          print("DISCONNECTED");

          _isConnected = false;

          TelegramWebApp.instance.showAlert('در حال اتصال به اینترنت');

          onChanged(false);
        }
      }
    });
  }

  static void stopConnectionCheck() {
    _timer?.cancel();
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

      print('🌍 Current origin: $currentOrigin');
      print('🌍 Current host: $currentHost');

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
      print('Error detecting environment: $e');
    }

    // پیش‌فرض
    return 'http://localhost:3000';
  }

  // متد کمکی برای دیباگ
  static void printEnvironmentInfo() {
    if (kIsWeb) {
      print('📱 Platform: Web');
      print('📍 Origin: ${Uri.base.origin}');
      print('📍 Host: ${Uri.base.host}');
      print('📍 Protocol: ${Uri.base.scheme}');
      print('🔌 Server URL: $serverUrl');
    } else {
      print('📱 Platform: Mobile/Desktop');
      print('🔌 Server URL: $serverUrl');
    }
  }
}
