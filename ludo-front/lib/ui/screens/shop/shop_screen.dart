import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/ui/screens/join-screen/join_screen_body/daily_reward_and_coin_box.dart';
import 'package:ludo/ui/screens/shop/buy_coins_tap.dart';
import 'package:ludo/ui/screens/shop/redeem_vpn_tap.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(
      gameControllerProvider.select((s) => s?.livePlayer),
    );

    final double screenWidth = MediaQuery.of(context).size.width;
    final double base = screenWidth.clamp(0, 600);

    final int userCoins = player?.coin ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF2A160C),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // هدر بالا: عنوان + نشانگر سکه کاربر
              Padding(
                padding: EdgeInsets.all(base * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.storefront_rounded,
                          color: const Color(0xFFFFD700),
                          size: base * 0.08,
                        ),
                        SizedBox(width: base * 0.025),
                        Text(
                          context.tr('shop'),
                          style: TextStyle(
                            color: const Color(0xFFFFF8DC),
                            fontSize: base * 0.06,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    CoinBox(
                      coins: userCoins,
                      height: 48, // ارتفاع قبلی 38 بود
                      fontSize: 16, // سایز فونت قبلی 13 بود
                      iconSize: 22, // سایز آیکون قبلی 16 بود
                    ),
                  ],
                ),
              ),

              // TabBar انتخاب خرید سکه / تبدیل به VPN
              Container(
                margin: EdgeInsets.symmetric(horizontal: base * 0.05),
                height: base * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E120B),
                  borderRadius: BorderRadius.circular(base * 0.035),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5A2B), Color(0xFF5C3613)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                  ),
                  labelColor: const Color(0xFFFFF8DC),
                  unselectedLabelColor: const Color(
                    0xFFFFF8DC,
                  ).withValues(alpha: 0.5),
                  labelStyle: TextStyle(
                    fontSize: base * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_shopping_cart_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(context.tr('Buy Coins')),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.vpn_key_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text(context.tr('Redeem VPN')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: base * 0.04),

              // بخش محتوای تب‌ها
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    BuyCoinsTab(base: base),
                    RedeemVpnTab(base: base, userCoins: userCoins),
                  ],
                ),
              ),

              // دکمه بازگشت به Home در انتهای صفحه
              Padding(
                padding: EdgeInsets.all(base * 0.05),
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(gameControllerProvider.notifier)
                        .updateState(
                          ref
                              .read(gameControllerProvider)
                              ?.copyWith(gameStage: GameStage.joinStage),
                        );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: base * 0.038),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5A2B), Color(0xFF5C3613)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(base * 0.035),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_rounded,
                          color: const Color(0xFFFFD700),
                          size: base * 0.055,
                        ),
                        SizedBox(width: base * 0.02),
                        Text(
                          context.tr('Home'),
                          style: TextStyle(
                            color: const Color(0xFFFFF8DC),
                            fontSize: base * 0.042,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

