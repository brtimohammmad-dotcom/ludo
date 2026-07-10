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
  bool _wasRolling = false; // فلگ کمکی برای جلوگیری از لوپ رندر

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // تغییر جزئی برای بهبود پرفورمنس ریپلد
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
    final currentTurn = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.currentTurn),
    );
    final turnStatus = ref.watch(
      gameControllerProvider.select((state) => state?.serverState?.turnStatus),
    );
    final lastDiceValue = ref.watch(
      gameControllerProvider.select(
        (state) => state?.serverState?.lastDiceValue ?? 1,
      ),
    );
    final bool isMyTurn = ref.watch(
      gameControllerProvider.select((state) => state.isMyTurnToRoll),
    );

    if (currentTurn == null) return const SizedBox.shrink();

    // 🔄 کنترل ساید‌افکت انیمیشن با استفاده از وضعیت پایدار استیت
    final bool isRolling = turnStatus == TurnStatus.rollDiceRequestInFlight;

    if (isRolling && !_wasRolling) {
      _wasRolling = true;
      // استفاده از فرستادن به فریم بعدی برای جلوگیری از تداخل متد بیلد
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _animationController.repeat();
      });
    } else if (!isRolling && _wasRolling) {
      _wasRolling = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.stop();
          _animationController.reverse(); // بازگشت امن اسکیل به ۱.۰
        }
      });
    }

    return AnimatedPositioned(
      curve: Curves.easeOutCirc,
      duration: const Duration(milliseconds: 400),
      left:
          dicePath[currentTurn.index].dy * widget.cellSize +
          (widget.cellSize / 4),
      top:
          dicePath[currentTurn.index].dx * widget.cellSize +
          (widget.cellSize / 4),
      child: GestureDetector(
        onTap: () {
          if (isMyTurn && !isRolling) {
            ref.read(gameControllerProvider.notifier).rollDice();
          }
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: SizedBox(
              width: widget.cellSize * 1.5,
              height: widget.cellSize * 1.5,
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
