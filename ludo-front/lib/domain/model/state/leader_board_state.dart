class LeaderboardItem {
  final String username;
  final int coin;

  LeaderboardItem({required this.username, required this.coin});

  // تبدیل JSON خام به شیء دارت
  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      username: json['username'] ?? 'Unknown',
      coin: json['coin'] ?? 0,
    );
  }
}

class LeaderboardStateData {
  final List<LeaderboardItem> topPlayers;
  final int currentUserRank;

  LeaderboardStateData({
    required this.topPlayers,
    required this.currentUserRank,
  });

  // تبدیل دیتای اصلی وب‌سوکت به این مدل
  factory LeaderboardStateData.fromJson(Map<String, dynamic> json) {
    var list = json['topPlayers'] as List? ?? [];
    List<LeaderboardItem> playersList =
    list.map((i) => LeaderboardItem.fromJson(i)).toList();

    return LeaderboardStateData(
      topPlayers: playersList,
      currentUserRank: json['currentUserRank'] ?? 0,
    );
  }
}