import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/game/logic/dice-logic/dice_logic.dart';
import 'package:ludo/ui/mappers/dice_mapper.dart';

class DiceWidget extends ConsumerStatefulWidget {
  final double cellSize;

  const DiceWidget({super.key, required this.cellSize});

  @override
  ConsumerState<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends ConsumerState<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // تعریف کنترلر انیمیشن برای چرخش مداوم تاس
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 ۱. گرفتن نوبت فعلی بازی
    final currentTurn = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.currentTurn),
    );

    // 🎯 ۲. وضعیت ریختن یا پردازش تاس روی سرور
    final turnStatus = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.turnStatus),
    );

    // 🎯 ۳. مقدار عددی آخرین تاس
    final lastDiceValue = ref.watch(
      gameControllerProvider.select(
        (state) => state?.serverState?.lastDiceValue ?? 1,
      ),
    );

    // 🎯 ۴. بررسی اینکه آیا نوبت این کاربر هست یا نه
    final bool isMyTurn = ref.watch(
      gameControllerProvider.select((state) => state.isMyTurnToRoll),
    );

    final gameControllerNotifier = ref.read(gameControllerProvider.notifier);

    if (currentTurn == null) return const SizedBox.shrink();

    // 🔄 مدیریت اجرای انیمیشن بر اساس وضعیت شرط سرور
    final bool isRolling = turnStatus == TurnStatus.rollDiceRequestInFlight;
    if (isRolling) {
      _rotationController.repeat(); // چرخش بی‌انتها در زمان درخواست سرور
    } else {
      _rotationController.stop(); // توقف انیمیشن زمان دریافت پاسخ
    }

    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 500),
      left:
          dicePath[currentTurn.index].dy * widget.cellSize +
          (widget.cellSize / 4),
      top:
          dicePath[currentTurn.index].dx * widget.cellSize +
          (widget.cellSize / 4),
      child: GestureDetector(
        onTap: () {
          // فقط در صورتی که نوبت پلیر باشد و در حال حاضر تاسی ریخته نشود، متد صدا زده شود
          if (isMyTurn && !isRolling) {
            gameControllerNotifier.rollDice();
          }
        },
        child: AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            // ۱. ابتدا ماتریس چرخش ۳ بعدی را بدون اسکیل می‌سازیم
            final transformMatrix = Matrix4.identity()
              ..setEntry(3, 2, 0.002) // افکت پرسپکتیو ۳ بعدی
              ..rotateZ(_rotationController.value * 2 * math.pi) // چرخش دوبعدی
              ..rotateY(
                isRolling ? _rotationController.value * 2 * math.pi : 0,
              ); // چرخش سه بعدی

            // ۲. حالا از خود ویجت استاندارد Transform.scale برای بزرگ‌نمایی استفاده می‌کنیم
            return Transform.scale(
              scale: isRolling ? 1.2 : 1.0,
              // تغییر اندازه کاملاً استاندارد و بدون ارور
              child: Transform(
                alignment: Alignment.center,
                transform: transformMatrix,
                child: child,
              ),
            );
          },
          child: AnimatedContainer(
            padding: EdgeInsets.all(
              isMyTurn ? widget.cellSize / 8 : widget.cellSize / 5,
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCirc,
            width: widget.cellSize * 1.5,
            height: widget.cellSize * 1.5,
            child: DiceWidgetMapper(
              isMyTurn: isMyTurn,
              value: lastDiceValue,
              size: 72,
            ),
          ),
        ),
      ),
    );
  }
}
