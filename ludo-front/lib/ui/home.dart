import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/ui/join_screen.dart';

class Home extends StatefulWidget {
  final GameController gameController;

  const Home({super.key, required this.gameController});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.gameController.connectToGame();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameController,
      builder: ((context, child) {
        return widget.gameController.livePlayer == null
            ? Center(
                child: Lottie.asset(
                  "assets/lotties/Happy girl.json",
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  frameRate: FrameRate(30),

                  renderCache: RenderCache.raster,
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: JoinScreen(gameController: widget.gameController),
                  ),
                ],
              );
      }),
    );
  }
}
