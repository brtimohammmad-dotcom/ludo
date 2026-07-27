import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_loading_provider.g.dart';

@riverpod
class GlobalLoading extends _$GlobalLoading {
  @override
  Set<String> build() => {}; // ذخیره کلید لودینگ‌ها به صورت منحصر‌به‌فرد (Set)

  /// روشن کردن یک لودینگ خاص
  void start(String key) {
    state = {...state, key};
  }

  /// خاموش کردن یک لودینگ خاص
  void stop(String key) {
    state = {for (final k in state) if (k != key) k};  }

  /// 🛑 خاموش کردن همه لودینگ‌ها یک‌جا (موقع قطعی اینترنت یا دیسکانکت سوکت)
  void clearAll() {
    state = {};
  }
}