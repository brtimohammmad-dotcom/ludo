import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/utils/avatar.dart';

class PlayerProfileAlert extends ConsumerWidget {
  const PlayerProfileAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(
      gameControllerProvider.select((s) => s?.livePlayer),
    );
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double base = (screenWidth * 0.85).clamp(0, 600);

    const Color emeraldColor = Color(0xFF4ADE80);

    final String name = player?.username ?? "Player";
    final String? avatarUrl = player?.avatarUrl;
    final int coins = player?.coin ?? 0;
    final int wins = player?.wins ?? 0;
    final int losses = player?.losses ?? 0;

    final List<VpnConfig> vpnConfigs = player?.vpnConfigs ?? [];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 24,
      ),
      child: Container(
        width: base,
        // محدود کردن حداکثر ارتفاع دیالوگ به ۸۰٪ ارتفاع صفحه جهت جلوگیری از overflow
        constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
        padding: EdgeInsets.all(base * 0.06),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(base * 0.06),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(
                url: avatarUrl,
                size: base * 0.22,
                borderColor: const Color(0xFFFFD700),
                borderWidth: 2,
              ),
              SizedBox(height: base * 0.03),

              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFFFFF8DC),
                  fontSize: base * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: base * 0.025),

              // سکه‌ها
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: base * 0.04,
                  vertical: base * 0.018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E120B),
                  borderRadius: BorderRadius.circular(base * 0.05),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: base * 0.05,
                      color: const Color(0xFFFFD700),
                    ),
                    SizedBox(width: base * 0.015),
                    Text(
                      context.num(coins),
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontSize: base * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: base * 0.04),

              // آمار برد و باخت
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: base * 0.035),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E120B),
                        borderRadius: BorderRadius.circular(base * 0.03),
                        border: Border.all(
                          color: emeraldColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr('Wins'),
                            style: TextStyle(
                              color: emeraldColor,
                              fontSize: base * 0.032,
                            ),
                          ),
                          SizedBox(height: base * 0.01),
                          Text(
                            context.num(wins),
                            style: TextStyle(
                              color: emeraldColor,
                              fontSize: base * 0.048,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: base * 0.03),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: base * 0.035),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E120B),
                        borderRadius: BorderRadius.circular(base * 0.03),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr('Losses'),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: base * 0.032,
                            ),
                          ),
                          SizedBox(height: base * 0.01),
                          Text(
                            context.num(losses),
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: base * 0.048,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // جداکننده (Divider)
              Padding(
                padding: EdgeInsets.symmetric(vertical: base * 0.03),
                child: Divider(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  thickness: 1,
                ),
              ),

              // -------------------------------------------------------------
              // بخش نمایش لیست کانفیگ‌های VPN
              // -------------------------------------------------------------
              Align(
                alignment: Alignment.center,
                child: Text(
                  context.tr('Your Subscriptions'),
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: base * 0.038,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: base * 0.02),

              if (vpnConfigs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(base * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E120B),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      context.tr('No active subscription found'),
                      style: TextStyle(
                        color: const Color(0xFFFFF8DC).withValues(alpha: 0.6),
                        fontSize: base * 0.032,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vpnConfigs.length,
                  separatorBuilder: (_, _) => SizedBox(height: base * 0.025),
                  itemBuilder: (context, index) {
                    final config = vpnConfigs[index];
                    return _VpnConfigCard(config: config, base: base);
                  },
                ),

              SizedBox(height: base * 0.04),

              // دکمه تایید/بستن
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: base * 0.035),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                    ),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(color: const Color(0xFFFFD700)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      context.tr('OK'),
                      style: TextStyle(
                        color: const Color(0xFFFFF8DC),
                        fontSize: base * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ویجت اختصاصی کارت کانفیگ VPN
class _VpnConfigCard extends StatelessWidget {
  final VpnConfig config;
  final double base;

  const _VpnConfigCard({required this.config, required this.base});

  @override
  Widget build(BuildContext context) {
    final double remainingGB = config.remainingGb;
    final double totalGB = config.totalGb;
    final int remainingDays = config.remainingDays;
    final String subscriptionUrl = config.subscriptionUrl;

    return Container(
      padding: EdgeInsets.all(base * 0.03),
      decoration: BoxDecoration(
        color: const Color(0xFF1E120B),
        borderRadius: BorderRadius.circular(base * 0.03),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // آمار حجم و زمان باقیمانده
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // حجم باقیمانده از کل
              Row(
                children: [
                  Icon(
                    Icons.data_usage_rounded,
                    color: const Color(0xFFFFD700),
                    size: base * 0.045,
                  ),
                  SizedBox(width: base * 0.015),
                  Text(
                    '${context.num(remainingGB.toStringAsFixed(1))} / ${context.num(totalGB.toStringAsFixed(0))} GB',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: const Color(0xFFFFF8DC),
                      fontSize: base * 0.034,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // روزهای باقیمانده
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: const Color(0xFF4ADE80),
                    size: base * 0.045,
                  ),
                  SizedBox(width: base * 0.015),
                  Text(
                    '${context.num(remainingDays)} ${context.tr('Days')}',
                    style: TextStyle(
                      color: const Color(0xFF4ADE80),
                      fontSize: base * 0.034,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: base * 0.02),

          // باکس لینک سابسکریپشن و دکمه کپی
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: base * 0.025,
              vertical: base * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(base * 0.02),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link_rounded,
                  color: const Color(0xFFFFD700),
                  size: base * 0.04,
                ),
                SizedBox(width: base * 0.015),
                Expanded(
                  child: Text(
                    subscriptionUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFFFFF8DC).withValues(alpha: 0.8),
                      fontSize: base * 0.028,
                    ),
                  ),
                ),
                SizedBox(width: base * 0.015),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.copy_rounded,
                    color: const Color(0xFFFFD700),
                    size: base * 0.045,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: subscriptionUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.tr('Link copied to clipboard!')),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
