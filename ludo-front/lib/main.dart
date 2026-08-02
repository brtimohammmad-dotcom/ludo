import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/app_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js_interop';

// تعریف نوع شیء تلگرام به صورت یک Extension Type روی JSObject
@JS('Telegram.WebApp')
extension type TelegramWebApp._(JSObject _) implements JSObject {
  // تعریف متدها به صورت external
  external static void ready();

  external static void expand();

  external static void disableVerticalSwipe();

  external static void enableClosingConfirmation();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    try {
      TelegramWebApp.ready();
      TelegramWebApp.expand();
      TelegramWebApp.disableVerticalSwipe();
      TelegramWebApp.enableClosingConfirmation();
      debugPrint('🚀 Telegram WebApp successfully locked via JS Interop.');
    } catch (e) {
      debugPrint(
        '⚠️ JS Interop failed (probably not running inside Telegram): $e',
      );
    }
  }
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
      title: 'Ludo Rush',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'), // یا متغیری که زبان فعلی را نگه می‌دارد
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fa', 'IR'), // فارسی
        Locale('en', 'US'), // انگلیسی
      ],

      // 🎯 بخش اصلی: تغییر پویای فونت بر اساس زبان برنامه
      builder: (context, child) {
        // ۱. دریافت زبان فعلی برنامه
        final currentLocale = Localizations.localeOf(context);
        final isPersian = currentLocale.languageCode == 'fa';

        final selectedFont = isPersian ? 'Vazirmatn' : 'Fredoka';

        // ۳. ساخت Theme اختصاصی بر اساس زبان فعال
        final currentTheme = ThemeData(
          fontFamily: selectedFont,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: selectedFont,
            letterSpacingDelta: 0,
          ),
        );

        // ۴. اعمال تم به‌روزرسانی شده به کل برنامه‌
        return Theme(
          data: currentTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },

      home: const AppBody(),
    );
  }
}