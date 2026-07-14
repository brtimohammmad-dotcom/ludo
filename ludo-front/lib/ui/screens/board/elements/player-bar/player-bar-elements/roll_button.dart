import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';

class RollButton extends ConsumerWidget {
  const RollButton({
    super.key,
    required this.boardSize,
  });

  final double boardSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 گوش دادن کاملاً مجزا و بهینه به وضعیت نوبت تاس
    final myTurnToRoll = ref.watch(
      gameControllerProvider.select((state) => state?.isMyTurnToRoll ?? false),
    );

    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);
    final borderRadius = BorderRadius.circular(8);

    // استایل‌های ثابت و کاملاً Solid (بدون محاسبات داینامیک گران‌قیمت در متریال دکمه)
    final activeGradient = LinearGradient(
      colors: [
        const Color(0xFF66BB6A), // سبز زنده و تخت
        const Color(0xFF43A047), // سبز پررنگ‌تر تخت
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final inactiveGradient = const LinearGradient(
      colors: [Color(0x33FFFFFF), Color(0x42FFFFFF)],
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: boardSize * 0.01),
      child: GestureDetector(
        // اگر نوبت کاربر بود متد اجرا شود، در غیر این صورت تاچ کاملاً خاموش است
        onTap: myTurnToRoll ? () => gameControllerNotifier.rollDice() : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150), // یک انیمیشن بسیار سبک برای تغییر حالت نوبت
          curve: Curves.easeIn,
          padding: EdgeInsets.symmetric(
            horizontal: boardSize * 0.05,
            vertical: boardSize * 0.015,
          ),
          decoration: BoxDecoration(
            gradient: myTurnToRoll ? activeGradient : inactiveGradient,
            borderRadius: borderRadius,
            // ⚡ استفاده از سایه تخت بدون بلور (Solid shadow) برای ایجاد عمق ۳ بعدی کاملاً بهینه
            boxShadow: myTurnToRoll
                ? [
              const BoxShadow(
                color: Color(0x661B5E20),
                blurRadius: 0,
                offset: Offset(0, 3),
              )
            ]
                : null,
            border: Border.all(
              color: myTurnToRoll ? const Color(0xFF81C784) : Colors.white10,
              width: 1.2,
            ),
          ),
          child: Text(
            'ROLL',
            style: TextStyle(
              color: myTurnToRoll ? Colors.white : Colors.white54,
              fontSize: boardSize * 0.025,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}