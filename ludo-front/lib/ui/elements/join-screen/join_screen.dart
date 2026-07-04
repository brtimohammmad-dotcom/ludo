import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/elements/join-screen/join_screen_handler.dart';
import 'package:ludo/ui/elements/join-screen/widgets/game_selection_buttons.dart';

enum GameMode { global, friendly }

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  bool _isAssetCached = false;
  late JoinScreenHandler _handler;

  @override
  void initState() {
    super.initState();

    _handler = JoinScreenHandler(
      context: context,
      gameController: ref.read(gameControllerProvider.notifier),
      audioService: ref.read(audioServiceProvider),
      isMounted: () => mounted,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handler.setupControllerCallbacks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAssetCached) {
      precacheImage(const AssetImage("assets/webp/happy-dice.webp"), context);
      _isAssetCached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight ? screenWidth : screenHeight * 0.86);

    // ⚡ دریافت مقدار سکه از گیم‌کنترلر (اگر نال بود مقدار 0 قرار می‌گیرد)
    // final userCoins = ref.watch(gameControllerProvider).coins ?? 0;
    final userCoins = 1000;

    return Scaffold(
      body: Stack(
        children: [
          // پس‌زمینه و محتوای اصلی دکمه‌ها
          Container(
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
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/webp/happy-dice.webp",
                    width: boardSize * 0.4,
                    height: boardSize * 0.4,
                    fit: BoxFit.cover,
                  ),
                  GameSelectionButtons(boardSize: boardSize, handler: _handler)
                ],
              ),
            ),
          ),

          // 🪙 ویجت نمایش تعداد سکه‌ها (بالا سمت چپ)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, // رعایت فاصله ناچ دستگاه
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$userCoins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Roboto', // یا هر فونتی که در پروژه داری
                    ),
                  ),
                ],
              ),
            ),
          ),

          // پریفچ کردن تصویر قدیمی شما
          Opacity(
            opacity: 0.0,
            child: Image.asset(
              "assets/webp/happy-dice.webp",
              width: 1,
              height: 1,
              cacheWidth: 10,
              cacheHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}