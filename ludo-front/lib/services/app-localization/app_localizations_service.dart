import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/languages/english.dart';
import 'package:ludo/services/app-localization/languages/persian.dart';

extension LocalizedBuildContext on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this).text(key);
  }
  String num(dynamic number) {
    return AppLocalizations.correctNumber(number.toString(), this);
  }
}

class AppLocalizations {
  static String correctNumber(String input, BuildContext context) {
    final isPersian = Localizations.localeOf(context).languageCode == 'fa';
    if (isPersian == false) return input;
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], persian[i]);
    }
    return input;
  }

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': enUS,
    'fa': faIR,
  };

  String text(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fa'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
