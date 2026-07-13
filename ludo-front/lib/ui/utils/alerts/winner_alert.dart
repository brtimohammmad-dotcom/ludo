import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/elements/join-screen/join_screen.dart';

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

    // محاسبه خودکار مبلغ جایزه بر اساس تعداد بازیکنان
    final winPrice =
        widget.gameController.currentGameState?.serverState?.numberOfPlayers ==
            2
        ? 180
        : 300;

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
                width: boardSize * 0.8,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff0f172a), // deep navy
                      Color(0xff1e293b), // slate
                      Color(0xff0b1320), // darker edge
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(120),
                      blurRadius: 35,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// 👑 ICON
                    Container(
                      padding: EdgeInsets.all(boardSize * 0.01),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withAlpha(200),
                            Colors.amber.withAlpha(60),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: boardSize * 0.3,
                        color: const Color(0xfffbbf24), // gold
                      ),
                    ),

                    SizedBox(height: boardSize * 0.12),

                    /// TITLE
                    Text(
                      "WINNER",
                      style: TextStyle(
                        fontSize: boardSize * 0.06,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),

                    SizedBox(height: boardSize * 0.1),

                    /// PLAYER NAME (glass effect)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: boardSize * 0.041,
                        vertical: boardSize * 0.022,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(40)),
                      ),
                      child: Text(
                        widget.winner.username,
                        style: TextStyle(
                          fontSize: boardSize * 0.03,
                          fontWeight: FontWeight.bold,
                          color: widget.winner.color?.toColor() ?? Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: boardSize * 0.05),

                    /// 💰 PRIZE AMOUNT SECTION
                    // تغییر این خط: استفاده امن از Collection-If بدون کلوش اضافی
                    if (widget
                            .gameController
                            .currentGameState
                            ?.serverState
                            ?.mode ==
                        GameMode.global)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: boardSize * 0.05,
                          vertical: boardSize * 0.02,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withAlpha(100),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: const Color(0xfffbbf24),
                              size: boardSize * 0.05,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "+$winPrice",
                              style: TextStyle(
                                fontSize: boardSize * 0.035,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xfffbbf24),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    /// BUTTON (gradient)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [Color(0xff22c55e), Color(0xff16a34a)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: boardSize * 0.04,
                            vertical: boardSize * 0.012,
                          ),
                        ),
                        onPressed: widget.gameController.exitGame,
                        child: Text(
                          "Back to Home",
                          style: TextStyle(
                            fontSize: boardSize * 0.02,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
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
