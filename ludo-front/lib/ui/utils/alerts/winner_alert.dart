import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class WinnerAlert extends ConsumerStatefulWidget {
  const WinnerAlert({
    super.key,
    required this.winner,
    required this.gameController,
  });

  final Player winner;
  final GameController gameController;

  @override
  ConsumerState<WinnerAlert> createState() => _WinnerAlertState();
}

class _WinnerAlertState extends ConsumerState<WinnerAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final ConfettiController _confetti;
  late final bool _isMeWinner;

  @override
  void initState() {
    super.initState();

    // تشخیص اینکه بازیکن محلی برنده شده است یا خیر
    final livePlayer = widget.gameController.currentGameState?.livePlayer;
    _isMeWinner = livePlayer?.userId == widget.winner.userId;

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    // پخش افکت صوتی داینامیک بر اساس برد یا باخت
    if (_isMeWinner) {
      ref
          .read(audioServiceProvider.notifier)
          .playSFX("assets/audio/sound-effect/winner_sound.wav");
      _confetti.play();
    } else {
      ref
          .read(audioServiceProvider.notifier)
          .playSFX("assets/audio/sound-effect/game_over_sound.wav");
    }

    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight
        ? screenWidth
        : screenHeight * 0.86);

    final double base = boardSize * 0.85;
    final winPrice = widget.gameController.currentGameState?.winPrice() ?? 0;
    final coinCost = widget.gameController.currentGameState?.reduceCoin() ?? 0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎉 CONFETTI (فقط برای برنده اصلی افکت پخش می‌شود)
          if (_isMeWinner)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.05,
                numberOfParticles: 25,
                gravity: 0.3,
              ),
            ),

          /// MAIN CARD
          ScaleTransition(
            scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
            child: FadeTransition(
              opacity: _anim,
              child: Container(
                width: base,
                padding: EdgeInsets.all(base * 0.06),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _isMeWinner
                        ? Colors.amber.withValues(alpha: 0.5)
                        : Colors.redAccent.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 👑 / ❌ ICON
                    Container(
                      padding: EdgeInsets.all(base * 0.02),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isMeWinner
                            ? Colors.amber.withValues(alpha: 0.1)
                            : Colors.redAccent.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _isMeWinner
                            ? Icons.emoji_events
                            : Icons.sentiment_very_dissatisfied,
                        size: base * 0.2,
                        color: _isMeWinner
                            ? Colors.amberAccent
                            : Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: base * 0.04),

                    /// TITLE (تغییر عنوان بر اساس وضعیت بازیکن)
                    Text(
                      _isMeWinner
                          ? context.tr("You Win")
                          : context.tr("Game Over"),
                      style: TextStyle(
                        fontSize: base * 0.07,
                        fontWeight: FontWeight.w900,
                        color: _isMeWinner ? Colors.white : Colors.redAccent,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: base * 0.04),

                    /// WINNER NAME BOX
                    Text(
                      _isMeWinner
                          ? context.tr("Congratulations")
                          : context.tr("Winner of this match"),
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: base * 0.032,
                      ),
                    ),
                    SizedBox(height: base * 0.02),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: base * 0.05,
                        vertical: base * 0.025,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        widget.winner.username,
                        style: TextStyle(
                          fontSize: base * 0.04,
                          fontWeight: FontWeight.bold,
                          color:
                          widget.winner.color?.name.toColor() ??
                              Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: base * 0.05),

                    /// 💰 PRIZE AMOUNT SECTION
                    if (widget
                        .gameController
                        .currentGameState
                        ?.serverState
                        ?.type ==
                        GameType.global) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: base * 0.05,
                          vertical: base * 0.025,
                        ),
                        decoration: BoxDecoration(
                          color: _isMeWinner
                              ? Colors.amber.withValues(alpha: 0.15)
                              : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isMeWinner
                                ? Colors.amber.withValues(alpha: 0.4)
                                : Colors.redAccent.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: _isMeWinner
                                  ? Colors.amber
                                  : Colors.redAccent,
                              size: base * 0.05,
                            ),
                            const SizedBox(width: 8),

                            /// انیمیشن شمارش سکه همراه با تبدیل اعداد به زبان جاری
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: (_isMeWinner ? winPrice : coinCost)
                                    .toDouble(),
                              ),
                              duration: Duration(
                                milliseconds:
                                (_isMeWinner ? winPrice : coinCost) * 20,
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                final animatedValue = value.toInt();
                                final targetValue =
                                (_isMeWinner ? winPrice : coinCost)
                                    .toDouble();

                                double progress = targetValue > 0
                                    ? value / targetValue
                                    : 1.0;

                                double scaleFactor =
                                    1.0 + (progress * (1.0 - progress) * 1.0);

                                // تبدیل عدد به عدد فارسی یا انگلیسی بر اساس زبان برنامه
                                final formattedNumber =
                                context.num(animatedValue);

                                return Transform.scale(
                                  scale: scaleFactor,
                                  child: Text(
                                    _isMeWinner
                                        ? "+$formattedNumber"
                                        : "-$formattedNumber",
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      fontSize: base * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: _isMeWinner
                                          ? Colors.amberAccent
                                          : Colors.white,
                                      shadows: [
                                        if (_isMeWinner)
                                          Shadow(
                                            color: Colors.amber
                                                .withValues(alpha: 0.5),
                                            blurRadius: 10,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: base * 0.06),
                    ],

                    /// BUTTON
                    GestureDetector(
                      onTap: widget.gameController.exitGame,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: base * 0.035,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E),
                              Color(0xFF15803D),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(base * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            context.tr("Back to Home"),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: base * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}