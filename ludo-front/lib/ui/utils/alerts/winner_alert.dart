import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/state/game_state.dart';
import 'package:ludo/domain/model/state/server_game_state.dart';
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

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    ref
        .read(audioServiceProvider)
        .playSFX("assets/audio/sound-effect/winner_sound.wav");
    _anim.forward();
    _confetti.play();
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

    final double base =
        boardSize * 0.85; // پایه مقیاس‌دهی هماهنگ با بقیه دیالوگ‌ها
    final winPrice = widget.gameController.currentGameState?.winPrice();

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎉 CONFETTI
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
                  color: const Color(0xFF1E293B), // تم تاریک منسجم بازی
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
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
                    /// 👑 ICON
                    Container(
                      padding: EdgeInsets.all(base * 0.02),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: base * 0.2,
                        color: Colors.amberAccent,
                      ),
                    ),
                    SizedBox(height: base * 0.04),

                    /// TITLE
                    Text(
                      "WINNER",
                      style: TextStyle(
                        fontSize: base * 0.07,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: base * 0.04),

                    /// PLAYER NAME
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
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: base * 0.05,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "+$winPrice",
                              style: TextStyle(
                                fontSize: base * 0.04,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                        padding: EdgeInsets.symmetric(vertical: base * 0.035),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF22C55E), // سبز نئونی شیک و جذاب
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
                            "Back to Home",
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
