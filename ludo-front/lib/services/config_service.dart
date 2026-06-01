import 'package:flutter/foundation.dart' show kIsWeb;
// ❌ حذف: import 'package:web/web.dart' as web;

class Config {
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