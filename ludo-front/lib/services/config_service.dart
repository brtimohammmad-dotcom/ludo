
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



class Config {

  static int reConnectCounter = 0;


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
