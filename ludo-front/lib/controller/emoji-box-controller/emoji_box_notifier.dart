import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emoji_box_notifier.g.dart';

@riverpod
class EmojiBoxNotifier extends _$EmojiBoxNotifier {
  @override
  bool build() {
    return false; // در ابتدا باکس ایموجی‌ها بسته است
  }

  // متدی برای تغییر وضعیت (باز به بسته / بسته به باز)
  void toggle() {
    state = !state;
  }

  // متدی برای بستن مستقیم باکس (مثلاً بعد از انتخاب ایموجی)
  void close() {
    state = false;
  }
}