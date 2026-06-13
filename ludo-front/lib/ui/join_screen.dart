import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/utils/alerts/reconnecting_failed_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';
import 'package:ludo/ui/elements/board/board.dart';
import 'package:ludo/ui/utils/animated_route.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  late final GameController gameController;
  bool showFriendsOptions = false;

  @override
  void initState() {
    super.initState();

    // ساخت کنترلر فقط یک‌بار
    gameController = GameController();

    if (TelegramWebApp.instance.isSupported) {
      TelegramWebApp.instance.ready();
      TelegramWebApp.instance.expand();
    }

    // اتصال سوکت فقط یک‌بار
    gameController.connectToGame();

    // هندل قطع اتصال
    gameController.gameRepository.dataSource.onDisconnectCallback = () {
      if (mounted && TelegramWebApp.instance.isSupported) {
        TelegramWebApp.instance.showAlert('Connection lost. Reconnecting...');
      }
    };
    // --- RECONNECTION FAILED ---
    gameController.onReconnectionFailed = () {
      if (!mounted) return;

      showAnimatedDialog(
        context: context,
        child: ReconnectingFailedAlert(
          onHomePressed: () async {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }

            gameController.deleteGameState();

            await Future.delayed(const Duration(milliseconds: 50));

            if (mounted) {
              gameController.connectToGame();
            }
          },
          textButton: "Reconnect",
        ),
      );
    };
    gameController.onGameRecovered = () {
      if (!mounted) return;

      // اگر همین الان در Board هستیم → هیچ کاری نکن
      if (gameController.isInBoard) return;

      // اگر در JoinScreen هستیم → برو Board
      Navigator.pushReplacement(
        context,
        animatedRoute(
          page: Board(gameController: gameController),
          duration: Duration(seconds: 1),
          type: RouteAnimation.scale,
        ),
      );
    };
  }

  @override
  void dispose() {
    // فقط اگر player در Board نیست، پاک کن
    if (!gameController.isInBoard && gameController.isDisposed) {
      gameController.deleteGameState();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameController,
      builder: (context, child) {
        final player = gameController.gameState?.livePlayer;

        return Scaffold(
          body: player == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Lottie.asset(
                        "assets/lotties/Happy girl.json",
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                        frameRate: FrameRate(30),
                        renderCache: RenderCache.raster,
                      ),
                      Text(
                        'Connecting to Server...',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.lightGreenAccent,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(-2, 3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey.shade500,
                        Colors.blueGrey,
                        Colors.blueGrey,
                        Colors.blueGrey.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(
                              "assets/lotties/Happy Dice.json",
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StartGameButton(
                                  gameController: gameController,
                                  gameMode: 2,
                                ),
                                const SizedBox(width: 10),
                                StartGameButton(
                                  gameController: gameController,
                                  gameMode: 4,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            StartGameButton(
                              gameController: gameController,
                              gameMode: -1,
                              onTap: () {
                                setState(() {
                                  showFriendsOptions = !showFriendsOptions;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 400),
                            AnimatedFriendsButtons(
                              show: showFriendsOptions,
                              gameController: gameController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class AnimatedFriendsButtons extends StatefulWidget {
  const AnimatedFriendsButtons({
    super.key,
    required this.show,
    required this.gameController,
  });

  final bool show;
  final GameController gameController;

  @override
  State<AnimatedFriendsButtons> createState() => _AnimatedFriendsButtonsState();
}

class _AnimatedFriendsButtonsState extends State<AnimatedFriendsButtons>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // مرحله ۱: fade-in + اسلاید از بالا به پایین (۰ تا ۰.6 از انیمیشن)
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideDownAnimation;

  // مرحله ۲: حرکت کوچک به بالا برای جاگیری نهایی (۰.6 تا ۱ از انیمیشن)
  late final Animation<Offset> _settleUpAnimation;

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1, curve: Curves.easeOut),
    );

    _slideDownAnimation =
        Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _settleUpAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.15)).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    if (widget.show) {
      _isVisible = true;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFriendsButtons oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.show != oldWidget.show) {
      if (widget.show) {
        setState(() => _isVisible = true);
        _controller.forward(from: 0);
      } else {
        _controller.reverse().then((_) {
          if (mounted) setState(() => _isVisible = false);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final combinedOffset = Offset(
          0,
          _slideDownAnimation.value.dy + _settleUpAnimation.value.dy,
        );

        return Opacity(
          opacity: _fadeAnimation.value,
          child: FractionalTranslation(
            translation: combinedOffset,
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StartGameButton(gameController: widget.gameController, gameMode: -2),
          const SizedBox(width: 10),
          StartGameButton(gameController: widget.gameController, gameMode: -4),
        ],
      ),
    );
  }
}

class StartGameButton extends StatelessWidget {
  const StartGameButton({
    super.key,
    required this.gameController,
    required this.gameMode,
    this.onTap,
  });

  final VoidCallback? onTap;

  final int gameMode;
  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(gameMode == -1 ? 250 : 120, 50),
        elevation: 3,
        backgroundColor: gameMode == -1 || gameMode == -2 || gameMode == -4
            ? Colors.amber
            : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      onPressed: () {
        if (gameMode == -1 && onTap != null) {
          onTap!();
          return; // ⬅️ از ادامه‌ی اجرای منطق اتصال جلوگیری می‌کند
        }
        // اینجا callback را ست می‌کنیم تا مقدار gameMode درست باشد
        gameController.onFastPingGets = () async {
          gameController.startGame(gameMode: gameMode);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    "assets/lotties/Happy girl.json",
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    frameRate: const FrameRate(30),
                    renderCache: RenderCache.raster,
                  ),
                  Text(
                    'Waiting for Game',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.lightGreenAccent,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 2,
                          offset: Offset(-2, 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        };

        gameController.onGameReady = () {
          if (Navigator.canPop(context)) Navigator.pop(context);

          Navigator.push(
            context,
            animatedRoute(
              page: Board(gameController: gameController),
              duration: Duration(seconds: 1),
              type: RouteAnimation.slideFromBottom,
            ),
          );
        };

        // اول تست اتصال
        gameController.getFastPing();
      },
      child: Text(
        gameMode == -1
            ? "Friends"
            : gameMode == 2||gameMode==-2
            ? "2 Players"
            : "4 Players",
        style: const TextStyle(color: Colors.white, height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }
}
