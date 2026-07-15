import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/emoji-box-controller/emoji_box_notifier.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/scroll_service.dart';

class EmojiBox extends ConsumerWidget {
  const EmojiBox({super.key, required this.boardSize, required this.cellSize});

  final double boardSize;
  final double cellSize;

  // 📝 تعریف مپ ایموجی‌ها و نام‌های متناظر برای فرستادن به بک‌اند
  static const Map<String, String> _emojiMap = {
    '😂': 'laugh',
    '😡': 'angry',
    '😢': 'cry',
    '😎': 'cool',
    '😮': 'shocked',
    '👍': 'thumbs_up',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmojiBoxOpen = ref.watch(emojiBoxProvider);
    // تبدیل مپ به لیست برای استفاده راحت‌تر در ListView.builder
    final emojiEntries = _emojiMap.entries.toList();

    final double boxWidth = cellSize * 3.5;

    return !isEmojiBoxOpen
        ? SizedBox.shrink()
        : Positioned(
            bottom: 4,
            // فرمول آپدیت شده برای وسط‌چین ماندن بر اساس عرض جدید (boxWidth)
            left: (boardSize - boxWidth) / 2,
            width: boxWidth,
            height: cellSize * 1.3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              // 🔄 استفاده از ListView افقی برای قابلیت اسکرول راحت
              child: ScrollConfiguration(
                behavior: WebScrollBehavior(),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojiEntries.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  // فیزیک اسکرول برای روان‌تر شدن حرکت در موبایل و وب
                  physics: const BouncingScrollPhysics(),

                  itemBuilder: (context, index) {
                    final entry = emojiEntries[index];
                    final String emojiIcon = entry.key; // '😂'
                    final String emojiName = entry.value; // 'laugh'

                    return GestureDetector(
                      onTap: () {
                        // 🚀 فرستادن نام انگلیسی ایموجی به سورس وب‌سوکت
                        ref
                            .read(gameControllerProvider.notifier)
                            .sendEmoji(emojiName);

                        // بستن خودکار باکس
                        ref.read(emojiBoxProvider.notifier).close();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          emojiIcon,
                          style: TextStyle(
                            // سایز ایموجی‌ها بزرگ‌تر شد تا انتخابشان راحت‌تر باشد
                            fontSize: cellSize * 0.90,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
