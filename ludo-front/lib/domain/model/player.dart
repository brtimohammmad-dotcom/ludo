import 'package:ludo/domain/model/state/vpn_config.dart';
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
  final String? lastClaimDate;
  final bool welcomeGift;
  String? avatarUrl;
  final int wins;
  final int losses;

  // فیلدهای VPN
  final List<VpnConfig> vpnConfigs;
  final int configCount;
  final int maxAllowedConfigs;

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
    this.lastClaimDate,
    this.welcomeGift = false, // 👈 مقداردهی اولیه
    this.avatarUrl,
    this.vpnConfigs = const [],
    this.configCount = 0,
    this.maxAllowedConfigs = 3,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    var vpnList = json['vpn_configs'] as List? ?? [];
    List<VpnConfig> parsedVpnConfigs =
    vpnList.map((configJson) => VpnConfig.fromJson(configJson)).toList();

    return Player(
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
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
      lastClaimDate: json['last_claim_date'],
      welcomeGift: json['welcome_gift'] ?? false, // 👈 دریافت از JSON

      // مقداردهی فیلدهای VPN
      vpnConfigs: parsedVpnConfigs,
      configCount: json['config_count'] ?? parsedVpnConfigs.length,
      maxAllowedConfigs: json['max_allowed_configs'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'telegram_id': userId,
    'coin': coin,
    'reward_streak': rewardStreak,
    'can_claim_daily_reward': canClaimDailyReward,
    'last_claim_date': lastClaimDate,
    'welcome_gift': welcomeGift, // 👈 تبدیل به JSON
    'avatar_url': avatarUrl,
    'vpn_configs': vpnConfigs.map((v) => v.toJson()).toList(),
    'config_count': configCount,
    'max_allowed_configs': maxAllowedConfigs,
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
    String? lastClaimDate,
    bool? welcomeGift, // 👈 اضافه شد به copyWith
    String? avatarUrl,
    int? wins,
    int? losses,
    List<VpnConfig>? vpnConfigs,
    int? configCount,
    int? maxAllowedConfigs,
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
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      welcomeGift: welcomeGift ?? this.welcomeGift, // 👈 پشتیبانی در copyWith
      vpnConfigs: vpnConfigs ?? this.vpnConfigs,
      configCount: configCount ?? this.configCount,
      maxAllowedConfigs: maxAllowedConfigs ?? this.maxAllowedConfigs,
    );
  }
}