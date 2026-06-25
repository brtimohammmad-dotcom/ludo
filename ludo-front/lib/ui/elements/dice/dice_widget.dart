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
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // یک کنترلر برای مدیریت هم‌زمان چرخش و اسکیل تاس
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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

    // 🔄 کنترل بهینه انیمیشن بدون لگ
    final bool isRolling = turnStatus == TurnStatus.rollDiceRequestInFlight;
    if (isRolling) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(); // چرخش بی‌انتها و بزرگ‌شدن تاس در حین درخواست
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop(); // توقف در زمان دریافت پاسخ
        _animationController.reverse(); // بازگشت اندازه به حالت عادی (۱.۰)
      }
    }

    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 400), // کمی سریع‌تر برای حس چابکی بیشتر
      left: dicePath[currentTurn.index].dy * widget.cellSize + (widget.cellSize / 4),
      top: dicePath[currentTurn.index].dx * widget.cellSize + (widget.cellSize / 4),
      child: GestureDetector(
        onTap: () {
          if (isMyTurn && !isRolling) {
            gameControllerNotifier.rollDice();
          }
        },
        // استفاده از ترنزیشن‌های پیش‌فرض فلاتر که مستقیماً روی GPU رندر می‌شوند
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: SizedBox(
              width: widget.cellSize * 1.5,
              height: widget.cellSize * 1.5,
              // حذف AnimatedContainer سنگین و استفاده از پدینگ ساده
              child: Padding(
                padding: EdgeInsets.all(
                  isMyTurn ? widget.cellSize / 8 : widget.cellSize / 5,
                ),
                child: DiceWidgetMapper(
                  isMyTurn: isMyTurn,
                  value: lastDiceValue,
                  size: 72,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}