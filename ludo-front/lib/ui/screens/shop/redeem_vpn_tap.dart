import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/utils/alerts/vpn_confirm_dialog.dart';
import 'package:ludo/ui/utils/alerts/vpn_success_dialog.dart';

class RedeemVpnTab extends ConsumerWidget {
  final double base;
  final int userCoins;

  const RedeemVpnTab({super.key, required this.base, required this.userCoins});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(gameControllerProvider.notifier).onVpnRedeemed = (VpnConfig vpnConfig) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // بستن دایالوگ Confirm
      }
      showAnimatedDialog(
        context: context,
        child: VpnSuccessDialog(vpnConfig: vpnConfig),
      );
    };
    final List<Map<String, dynamic>> vpnOffers = [
      {'gb': 1, 'cost': 10000, 'days': 30},
      {'gb': 3, 'cost': 25000, 'days': 30},
      {'gb': 5, 'cost': 40000, 'days': 30},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: base * 0.05),
      children: [
        Text(
          context.tr(
            'Exchange your game coins for high-speed VPN subscription links',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFFFF8DC).withValues(alpha: 0.7),
            fontSize: base * 0.03,
          ),
        ),
        SizedBox(height: base * 0.04),

        ...vpnOffers.map((offer) {
          final int cost = offer['cost'];
          final int gb = offer['gb'];
          final int days = offer['days'];
          final bool canAfford = userCoins >= cost;

          final String title =
              '${context.num(gb)} ${context.tr('GB')} - ${context.num(days)} ${context.tr('Days')}';

          final Map<String, dynamic> offerWithTitle = {
            ...offer,
            'title': title,
          };

          return Container(
            margin: EdgeInsets.only(bottom: base * 0.03),
            padding: EdgeInsets.all(base * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF1E120B),
              borderRadius: BorderRadius.circular(base * 0.035),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vpn_lock_rounded,
                          color: const Color(0xFF4ADE80),
                          size: base * 0.07,
                        ),
                        SizedBox(width: base * 0.03),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: const Color(0xFFFFF8DC),
                                fontSize: base * 0.038,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: base * 0.012),

                            // کانتینر شیک و جداگانه برای نمایش روزها
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: base * 0.02,
                                vertical: base * 0.006,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFD700,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  base * 0.015,
                                ),
                                border: Border.all(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.3),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_filled_rounded,
                                    color: const Color(0xFFFFD700),
                                    size: base * 0.028,
                                  ),
                                  SizedBox(width: base * 0.01),
                                  Text(
                                    '${context.num(days)} ${context.tr('Days Availability')}',
                                    style: TextStyle(
                                      color: const Color(0xFFFFD700),
                                      fontSize: base * 0.025,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: const Color(0xFFFFD700),
                          size: base * 0.05,
                        ),
                        SizedBox(width: base * 0.012),
                        Text(
                          context.num(cost),
                          style: TextStyle(
                            color: const Color(0xFFFFD700),
                            fontSize: base * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: base * 0.03),

                GestureDetector(
                  onTap: canAfford
                      ? () {
                          showAnimatedDialog(
                            context: context,
                            child: VpnConfirmDialog(
                              base: base,
                              offer: offerWithTitle,
                              userCoins: userCoins,
                              onConfirm: () {
                                ref
                                    .read(gameControllerProvider.notifier)
                                    .startLoading('redeem_vpn');
                                ref
                                    .read(gameControllerProvider.notifier)
                                    .redeemVpn(gb: gb);
                              },
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: base * 0.026),
                    decoration: BoxDecoration(
                      gradient: canAfford
                          ? const LinearGradient(
                              colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                            )
                          : null,
                      color: canAfford
                          ? null
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(base * 0.025),
                      border: Border.all(
                        color: canAfford
                            ? const Color(0xFF4ADE80)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        canAfford
                            ? context.tr('Redeem Now')
                            : context.tr('Not Enough Coins'),
                        style: TextStyle(
                          color: canAfford ? Colors.black : Colors.white38,
                          fontSize: base * 0.034,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
