import 'package:flutter/material.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class BuyCoinsTab extends StatelessWidget {
  final double base;

  const BuyCoinsTab({super.key, required this.base});

  @override
  Widget build(BuildContext context) {
    // قیمت‌ها به تومان تعریف شده‌اند
    final List<Map<String, dynamic>> packages = [
      {'coins': 5000, 'price': 5000, 'popular': false},
      {'coins': 10000, 'price': 10000, 'popular': false},
      {'coins': 25000, 'price': 25000, 'popular': false},
      {'coins': 40000, 'price': 40000, 'popular': false},
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: base * 0.05),
      children: [
        SizedBox(height: base * 0.02),

        // کارت‌های پکیج سکه
        ...packages.map((pkg) {
          final bool isPopular = pkg['popular'];
          final int price = pkg['price'];

          return Container(
            margin: EdgeInsets.only(bottom: base * 0.03),
            padding: EdgeInsets.all(base * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xFF1E120B),
              borderRadius: BorderRadius.circular(base * 0.035),
              border: Border.all(
                color: isPopular
                    ? const Color(0xFFFFD700)
                    : const Color(0xFFFFD700).withValues(alpha: 0.25),
                width: isPopular ? 2.0 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: const Color(0xFFFFD700),
                      size: base * 0.08,
                    ),
                    SizedBox(width: base * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${context.num(pkg['coins'])} ${context.tr('Coins')}',
                              style: TextStyle(
                                color: const Color(0xFFFFF8DC),
                                fontSize: base * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isPopular) ...[
                              SizedBox(width: base * 0.02),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: base * 0.02,
                                  vertical: base * 0.006,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(
                                    base * 0.015,
                                  ),
                                ),
                                child: Text(
                                  context.tr('BEST VALUE'),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: base * 0.022,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: اتصال به درگاه پرداخت مستقیم
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5A2B),
                    foregroundColor: const Color(0xFFFFF8DC),
                    side: const BorderSide(color: Color(0xFFFFD700)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(base * 0.025),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: base * 0.035,
                      vertical: base * 0.018,
                    ),
                  ),
                  child: Text(
                    '${context.num(price)} ${context.tr('Toman')}',
                    style: TextStyle(
                      fontSize: base * 0.032,
                      fontWeight: FontWeight.bold,
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
