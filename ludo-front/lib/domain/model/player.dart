import 'package:ludo/domain/model/token.dart';


enum PlayerStatus { online, offline }

class Player {
  final int userId;
  final String username;
  final int coin;
  final PlayerColor? color;
  final PlayerStatus? playerStatus;
  final int? numberOfAbsences;
  final int rewardStreak;
  final bool canClaimDailyReward;

  Player({
    required this.coin,
    required this.numberOfAbsences,
    required this.userId,
    required this.username,
    required this.color,
    required this.playerStatus,
    this.rewardStreak = 1,          // مقدار پیش‌فرض ۱
    this.canClaimDailyReward = false, // مقدار پیش‌فرض غیرفعال
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      coin: json['coin'] ?? 0,
      numberOfAbsences: json['numberOfAbsences'],
      username: json['username'] ?? '',
      color: json['color'] == null
          ? null
          : PlayerColor.values.byName(json['color']),
      userId: json['telegram_id'],
      playerStatus: json['player_status'] == null
          ? null
          : PlayerStatus.values.byName(json['player_status']),

      rewardStreak: json['reward_streak'] ?? 1,
      canClaimDailyReward: json['can_claim_daily_reward'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'telegram_id': userId,
    'coin': coin,
    'reward_streak': rewardStreak,
    'can_claim_daily_reward': canClaimDailyReward,
  };

  Player copyWith({
    int? userId,
    String? username,
    int? coin,
    PlayerColor? color,
    PlayerStatus? playerStatus,
    int? numberOfAbsences,
    int? rewardStreak,
    bool? canClaimDailyReward,
  }) {
    return Player(
      coin: coin ?? this.coin,
      numberOfAbsences: numberOfAbsences ?? this.numberOfAbsences,
      playerStatus: playerStatus ?? this.playerStatus,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      color: color ?? this.color,
      // 🔄 اضافه شدن به کپی‌ویت برای آپدیت راحت در کنترلر
      rewardStreak: rewardStreak ?? this.rewardStreak,
      canClaimDailyReward: canClaimDailyReward ?? this.canClaimDailyReward,
    );
  }
}