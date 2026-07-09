import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ludo/ui/app_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ۲. مدیریت و خنثی‌سازی ارورهای زامبی فلاتر وب در حالت Hot Restart
  if (kIsWeb && kDebugMode) {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorStr = details.exception.toString();

      // اگر خطای مربوط به ویوهای دیسپوز شده وب بود، بی‌صدا ردش کن تا برنامه بالا بیاید
      if (errorStr.contains('EngineFlutterView') ||
          errorStr.contains('!isDisposed') ||
          errorStr.contains('transitMode')) {
        debugPrint('🧹 Ignored Web Engine zombie error during Hot Restart.');
        return;
      }

      // بقیه خطاهای واقعی برنامه را طبق روال عادی نشان بده
      originalOnError?.call(details);
    };
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      title: 'Ludo',
      debugShowCheckedModeBanner: false,
      // 🟢 شفاف کردن کامل پس‌زمینه تم اصلی اپلیکیشن وب
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const AppBody(),
    );
  }
}
