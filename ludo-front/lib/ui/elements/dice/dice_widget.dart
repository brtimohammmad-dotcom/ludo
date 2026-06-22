import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';
import 'package:ludo/ui/mappers/dice_mapper.dart';

class DiceWidget extends ConsumerWidget {
  final double cellSize;
  final Future<LottieComposition> diceComposition;

  const DiceWidget({
    super.key,
    required this.cellSize,
    required this.diceComposition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 ۱. گرفتن نوبت فعلی بازی برای جابه‌جایی مختصات انیمیشنی تاس روی بورد
    final currentTurn = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.currentTurn),
    );

    // 🎯 ۲. وضعیت ریختن یا پردازش تاس روی سرور
    final turnStatus = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.turnStatus),
    );

    // 🎯 ۳. مقدار عددی آخرین تاس برای تغییر ظاهرِ مپر گرافیکی تاس
    final lastDiceValue = ref.watch(
      gameControllerProvider.select(
        (state) => state?.serverState?.lastDiceValue ?? 1,
      ),
    );

    // 🎯 ۴. بررسی اینکه آیا نوبت این کاربر هست یا نه (با استفاده از اکستنشن بهینه قبلی)
    final bool isMyTurn = ref.watch(
      gameControllerProvider.select((state) => state.isMyTurnToRoll),
    );

    // نوتیفایر صرفاً برای صدا زدن متد اکشن
    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);

    // اگر بازی هنوز لود نشده یا وضعیت نوبت مشخص نیست، چیزی رندر نشود
    if (currentTurn == null) return const SizedBox.shrink();

    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      // 🟢 حالا به جای لود کردن مستقیم از استیت، از مقادیر سلکت شده استفاده می‌کنیم
      left: dicePath[currentTurn.index].dy * cellSize + (cellSize / 4),
      top: dicePath[currentTurn.index].dx * cellSize + (cellSize / 4),
      child: GestureDetector(
        onTap: () {
          gameControllerNotifier.rollDice();
        },
        child: turnStatus == TurnStatus.rollDiceRequestInFlight
            ? Lottie.asset(
                "assets/lotties/Dice Rolling.json",
                width: cellSize * 1.5,
                height: cellSize * 1.5,
                fit: BoxFit.cover,
              )
            : AnimatedContainer(
                padding: EdgeInsets.all(isMyTurn ? cellSize / 8 : cellSize / 5),
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                width: cellSize * 1.5,
                height: cellSize * 1.5,
                child: DiceWidgetMapper(
                  isMyTurn: isMyTurn,
                  value: lastDiceValue,
                  size: 72,
                ),
              ),
      ),
    );
  }
}
