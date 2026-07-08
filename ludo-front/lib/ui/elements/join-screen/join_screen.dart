import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/services/audio_service.dart';
import 'package:ludo/ui/elements/join-screen/join_screen_handler.dart';
import 'package:ludo/ui/elements/join-screen/widgets/coin_box.dart';
import 'package:ludo/ui/elements/join-screen/widgets/game_selection_buttons.dart';

enum GameMode { global, friendly }

class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = (screenWidth < screenHeight ? screenWidth : screenHeight * 0.86);
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

          CoinBox(boardSize: boardSize,),

        ],
      ),
    );
  }
}

