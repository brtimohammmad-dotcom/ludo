import 'package:ludo/domain/model/state/leader_board_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'leader_board.g.dart';

// یک پرووایدر ساده برای نگهداری دیتای لیدربرد
@Riverpod(keepAlive: true)
class LeaderboardDataNotifier extends _$LeaderboardDataNotifier {
  @override
  LeaderboardStateData? build() {
    return null; // در ابتدا دیتایی وجود ندارد
  }

  // متدی برای به‌روزرسانی دیتا به محض رسیدن از وب‌سوکت
  void updateData(Map<String, dynamic> jsonResponse) {
    state = LeaderboardStateData.fromJson(jsonResponse);
  }
}