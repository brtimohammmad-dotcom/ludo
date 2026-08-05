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
  String? avatarUrl;
  final int wins;
  final int losses;

  Player({
    required this.coin,
    required this.numberOfAbsences,
    required this.userId,
    required this.username,
    required this.color,
    required this.playerStatus,
    required this.wins,
    required this.losses,
    this.rewardStreak = 1,
    this.canClaimDailyReward = false,
    this.avatarUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      wins: json['wins'],
      losses: json['losses'],
      avatarUrl: json['avatar_url'],
      coin: json['coin'] ?? 0,
      numberOfAbsences: json['number_of_absences'],
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
    'avatar_url': avatarUrl,
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
    String? avatarUrl,
    int? wins,
    int? losses,
  }) {
    return Player(
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coin: coin ?? this.coin,
      numberOfAbsences: numberOfAbsences ?? this.numberOfAbsences,
      playerStatus: playerStatus ?? this.playerStatus,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      color: color ?? this.color,
      rewardStreak: rewardStreak ?? this.rewardStreak,
      canClaimDailyReward: canClaimDailyReward ?? this.canClaimDailyReward,
    );
  }
}
