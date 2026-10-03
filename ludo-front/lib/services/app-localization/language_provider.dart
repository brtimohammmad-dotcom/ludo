import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_provider.g.dart';

@Riverpod(keepAlive: true)
class Language extends _$Language {
  @override
  Locale build() {
    // زبان پیش‌فرض برنامه (مثلاً فارسی)
    return const Locale('en', 'Us');
  }

  /// تغییر زبان بین فارسی و انگلیسی
  void toggleLanguage() {
    if (state.languageCode == 'fa') {
      state = const Locale('en', 'US');
    } else {
      state = const Locale('fa', 'IR');
    }
  }

  /// تنظیم مستقیم یک زبان خاص
  void setLanguage(String languageCode) {
    if (state.languageCode != languageCode) {
      state = Locale(languageCode);
    }
  }

  /// آیا زبان فعلی انگلیسی است؟
  bool get isEnglish => state.languageCode == 'en';
}
