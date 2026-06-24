import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/player.dart';
import 'package:ludo/domain/model/token.dart';
import 'package:ludo/services/audio_service.dart';

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

    _confetti = ConfettiController(
      duration: const Duration(seconds: 3),
    );
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
    final size = MediaQuery.of(context).size;

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
            scale: CurvedAnimation(
              parent: _anim,
              curve: Curves.elasticOut,
            ),
            child: FadeTransition(
              opacity: _anim,
              child:  Container(
              width: size.width * 0.8,
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
                    padding: const EdgeInsets.all(16),
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
                    child: const Icon(
                      Icons.emoji_events,
                      size: 85,
                      color: Color(0xfffbbf24), // gold
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// TITLE
                  const Text(
                    "WINNER",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// PLAYER NAME (glass effect)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withAlpha(40),
                      ),
                    ),
                    child: Text(
                      widget.winner.username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.winner.color?.toColor() ?? Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  /// BUTTON (gradient)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff22c55e),
                          Color(0xff16a34a),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      onPressed: widget.gameController.exitGame,
                      child: const Text(
                        "Back to Home",
                        style: TextStyle(
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