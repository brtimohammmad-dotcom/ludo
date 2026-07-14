import 'dart:async';
import 'package:ludo/domain/model/token.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_emoji_notifier.g.dart';

class ActiveEmojisState {
  final String? red;
  final String? green;
  final String? yellow;
  final String? blue;

  ActiveEmojisState({this.red, this.green, this.yellow, this.blue});

  ActiveEmojisState copyWith({String? red, String? green, String? yellow, String? blue}) {
    return ActiveEmojisState(
      red: red ?? this.red,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      blue: blue ?? this.blue,
    );
  }
}

@Riverpod(keepAlive: true)
class ActiveEmojiNotifier extends _$ActiveEmojiNotifier {
  final Map<PlayerColor, Timer?> _timers = {};

  @override
  ActiveEmojisState build() {
    return ActiveEmojisState();
  }

  // این متد به محض دریافت دیتای ایموجی از کنترلر اصلی وب‌سوکت شما صدا زده می‌شود
  void showEmoji(PlayerColor color, String emoji) {
    // لغو تایمر قبلی برای این رنگ در صورت وجود
    _timers[color]?.cancel();

    // به‌روزرسانی استیت برای نمایش ایموجی
    if (color == PlayerColor.red) state = state.copyWith(red: emoji);
    if (color == PlayerColor.green) state = state.copyWith(green: emoji);
    if (color == PlayerColor.yellow) state = state.copyWith(yellow: emoji);
    if (color == PlayerColor.blue) state = state.copyWith(blue: emoji);

    // محو شدن خودکار ایموجی پس از ۳ ثانیه
    _timers[color] = Timer(const Duration(seconds: 3), () {
      if (color == PlayerColor.red) state = state.copyWith(red: '');
      if (color == PlayerColor.green) state = state.copyWith(green: '');
      if (color == PlayerColor.yellow) state = state.copyWith(yellow: '');
      if (color == PlayerColor.blue) state = state.copyWith(blue: '');
    });
  }
}