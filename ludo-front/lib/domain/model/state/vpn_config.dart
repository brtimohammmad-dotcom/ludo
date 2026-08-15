class VpnConfig {
  final String subscriptionUrl;
  final double totalGb;
  final double remainingGb;
  final int remainingDays;
  final String status;

  VpnConfig({
    required this.subscriptionUrl,
    required this.totalGb,
    required this.remainingGb,
    required this.remainingDays,
    this.status = 'ENABLE',
  });

  factory VpnConfig.fromJson(Map<String, dynamic> json) {
    return VpnConfig(
      subscriptionUrl: json['subscriptionUrl'] ?? '',
      totalGb: (json['totalGb'] ?? 0).toDouble(),
      remainingGb: (json['remainingGb'] ?? 0).toDouble(),
      remainingDays: json['remainingDays'] ?? 0,
      status: json['status'] ?? 'ENABLE',
    );
  }

  Map<String, dynamic> toJson() => {
    'subscriptionUrl': subscriptionUrl,
    'totalGb': totalGb,
    'remainingGb': remainingGb,
    'remainingDays': remainingDays,
    'status': status,
  };

  VpnConfig copyWith({
    String? subscriptionUrl,
    double? totalGb,
    double? remainingGb,
    int? remainingDays,
    String? status,
  }) {
    return VpnConfig(
      subscriptionUrl: subscriptionUrl ?? this.subscriptionUrl,
      totalGb: totalGb ?? this.totalGb,
      remainingGb: remainingGb ?? this.remainingGb,
      remainingDays: remainingDays ?? this.remainingDays,
      status: status ?? this.status,
    );
  }
}