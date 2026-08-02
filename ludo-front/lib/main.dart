import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/services/app-localization/language_provider.dart';
import 'package:ludo/ui/app_body.dart';

// -----------------------------------------------------------------------------
// تعریف نوع شیء تلگرام به صورت Extension Type روی JSObject
// -----------------------------------------------------------------------------
@JS('Telegram.WebApp')
extension type TelegramWebApp._(JSObject _) implements JSObject {
  external static void ready();
  external static void expand();
  external static void disableVerticalSwipe();
  external static void enableClosingConfirmation();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ۱. مقداردهی اولیه محیط تلگرام در وب
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

      if (errorStr.contains('EngineFlutterView') ||
          errorStr.contains('!isDisposed') ||
          errorStr.contains('transitMode')) {
        debugPrint('🧹 Ignored Web Engine zombie error during Hot Restart.');
        return;
      }

      originalOnError?.call(details);
    };
  }

  runApp(const ProviderScope(child: MyApp()));
}

// -----------------------------------------------------------------------------
// ویجت اصلی ریشه برنامه (ConsumerWidget برای واکنش آنی به تغییرات Riverpod)
// -----------------------------------------------------------------------------
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 دریافت هم‌زمان Locale فعلی از پرووایدر
    final currentLocale = ref.watch(languageProvider);
    final isPersian = currentLocale.languageCode == 'fa';
    final selectedFont = isPersian ? 'Vazirmatn' : 'Fredoka';

    // 🎯 ساخت تم و فونت هم‌گام با Locale بدون نیاز به builder متناقض
    final appTheme = ThemeData(
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

    return MaterialApp(
      title: 'Ludo Rush',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      theme: appTheme,
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
      home: const AppBody(),
    );
  }
}