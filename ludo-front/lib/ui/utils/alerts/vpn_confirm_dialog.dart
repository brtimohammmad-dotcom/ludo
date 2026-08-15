import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class VpnConfirmDialog extends ConsumerWidget {
  final double base;
  final Map<String, dynamic> offer;
  final int userCoins;
  final VoidCallback onConfirm;

  const VpnConfirmDialog({
    super.key,
    required this.base,
    required this.offer,
    required this.userCoins,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final redeemRequestInFlight = ref.watch(
      globalLoadingProvider.select((s) => s.contains('redeem_vpn')),
    );
    final int cost = offer['cost'];
    final bool canAfford = userCoins >= cost;

    return AlertDialog(
      backgroundColor: const Color(0xFF2A160C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(base * 0.04),
        side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
      title: Text(
        context.tr('Confirm Exchange'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFFFFF8DC),
          fontSize: base * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr(
              'Are you sure you want to exchange coins for this VPN plan?',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFFF8DC).withValues(alpha: 0.8),
              fontSize: base * 0.032,
            ),
          ),
          SizedBox(height: base * 0.03),
          // باکس خلاصه کارت
          Container(
            padding: EdgeInsets.all(base * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF1E120B),
              borderRadius: BorderRadius.circular(base * 0.025),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offer['title'],
                  style: TextStyle(
                    color: const Color(0xFFFFF8DC),
                    fontWeight: FontWeight.bold,
                    fontSize: base * 0.035,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: const Color(0xFFFFD700),
                      size: base * 0.045,
                    ),
                    SizedBox(width: base * 0.01),
                    Text(
                      context.num(cost),
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: base * 0.035,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        // دکمه لغو (فقط در صورتی فعال است که در حال لودینگ نباشیم)
        TextButton(
          onPressed: redeemRequestInFlight
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(
            context.tr('Cancel'),
            style: TextStyle(
              color: redeemRequestInFlight ? Colors.white24 : Colors.white70,
              fontSize: base * 0.035,
            ),
          ),
        ),
        // دکمه تایید
        ElevatedButton(
          // در صورت عدم موجودی یا در حال لودینگ بودن، دکمه غیرفعال می‌شود تا چند بار کلیک نشود
          onPressed: (canAfford && !redeemRequestInFlight)
              ? () => onConfirm()
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford
                ? const Color(0xFF16A34A)
                : Colors.grey.withValues(alpha: 0.3),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(base * 0.02),
            ),
          ),
          child: redeemRequestInFlight
              ? SizedBox(
            width: base * 0.045,
            height: base * 0.045,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
              : Text(
            canAfford
                ? context.tr('Confirm')
                : context.tr('Not Enough Coins'),
            style: TextStyle(
              fontSize: base * 0.034,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}