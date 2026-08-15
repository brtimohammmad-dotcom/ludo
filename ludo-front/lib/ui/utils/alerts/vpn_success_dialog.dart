import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo/domain/model/state/vpn_config.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class VpnSuccessDialog extends StatelessWidget {
  final VpnConfig vpnConfig;

  const VpnSuccessDialog({super.key, required this.vpnConfig});

  @override
  Widget build(BuildContext context) {
    // محاسبه خودکار پایه ابعاد بر اساس عرض صفحه
    final double base = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: const Color(0xFF2A160C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(base * 0.04),
        side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
      ),
      title: Column(
        children: [
          Container(
            padding: EdgeInsets.all(base * 0.03),
            decoration: const BoxDecoration(
              color: Color(0xFF16A34A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: base * 0.08,
            ),
          ),
          SizedBox(height: base * 0.02),
          Text(
            context.tr('VPN Purchased Successfully!'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFFF8DC),
              fontSize: base * 0.042,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.tr(
              'Your VPN subscription link is ready. Copy it and paste into your VPN client.',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFFFF8DC).withValues(alpha: 0.8),
              fontSize: base * 0.032,
            ),
          ),
          SizedBox(height: base * 0.03),
          // باکس خلاصه کانفیگ و لینک اشتراک
          Container(
            padding: EdgeInsets.all(base * 0.03),
            decoration: BoxDecoration(
              color: const Color(0xFF1E120B),
              borderRadius: BorderRadius.circular(base * 0.025),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('Total Traffic:'),
                      style: TextStyle(
                        color: const Color(0xFFFFF8DC).withValues(alpha: 0.7),
                        fontSize: base * 0.03,
                      ),
                    ),
                    Text(
                      '${context.num(vpnConfig.totalGb.toInt())} GB',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: base * 0.032,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: base * 0.015),
                Text(
                  context.tr('Subscription URL:'),
                  style: TextStyle(
                    color: const Color(0xFFFFF8DC).withValues(alpha: 0.7),
                    fontSize: base * 0.03,
                  ),
                ),
                SizedBox(height: base * 0.01),
                // کادر کپی لینک
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: base * 0.02,
                    vertical: base * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF120A06),
                    borderRadius: BorderRadius.circular(base * 0.015),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vpnConfig.subscriptionUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFFFFF8DC),
                            fontSize: base * 0.028,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      SizedBox(width: base * 0.01),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: vpnConfig.subscriptionUrl),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.tr('Link copied to clipboard!'),
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(base * 0.015),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(base * 0.01),
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            color: const Color(0xFF2A160C),
                            size: base * 0.035,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF2A160C),
            padding: EdgeInsets.symmetric(
              horizontal: base * 0.08,
              vertical: base * 0.015,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(base * 0.02),
            ),
          ),
          child: Text(
            context.tr('Got it'),
            style: TextStyle(
              fontSize: base * 0.036,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
