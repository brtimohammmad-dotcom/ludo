import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/audio_service.dart';
import 'start_game_button.dart';
import 'animated_friends_buttons.dart';

class GameSelectionButtons extends ConsumerStatefulWidget {
  final double boardSize;
  final dynamic handler; // کلاس JoinScreenHandler شما

  const GameSelectionButtons({
    super.key,
    required this.boardSize,
    required this.handler,
  });

  @override
  ConsumerState<GameSelectionButtons> createState() => _GameSelectionButtonsState();
}

class _GameSelectionButtonsState extends ConsumerState<GameSelectionButtons> {
  // تعریف ناظر وضعیت بدون نیاز به setState
  final ValueNotifier<bool> _showFriendsNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    // حتماً برای جلوگیری از نشت حافظه (Memory Leak) آن را دیسپوز کن
    _showFriendsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StartGameButton(
              numberOfPlayers: 2,
              entryFee: 100,
              prizePool: 180,
              onPressed: () => widget.handler.handleGameSearch(2, widget.boardSize),
              boardSize:widget.boardSize
            ),
             SizedBox(width: widget.boardSize*0.01),
            StartGameButton(
              entryFee: 100,
              prizePool: 300,
              numberOfPlayers: 4,
              onPressed: () => widget.handler.handleGameSearch(4, widget.boardSize),
                boardSize:widget.boardSize

            ),
          ],
        ),
        SizedBox(height: widget.boardSize*0.01),
        StartGameButton(
          entryFee: 0,
          prizePool: 0,
          numberOfPlayers: -1,
          onPressed: () {
            ref.read(audioServiceProvider).playSFX(
              'assets/audio/sound-effect/friend_button_sound.wav',
            );
            // تغییر مقدار بدون صدا زدن setState
            _showFriendsNotifier.value = !_showFriendsNotifier.value;
          },
            boardSize:widget.boardSize

        ),
        SizedBox(height: widget.boardSize*0.025),

        // جادوی اصلی اینجاست: فقط این بخش کوچک به تغییرات گوش می‌دهد و ری‌بیلد می‌شود
        ValueListenableBuilder<bool>(
          valueListenable: _showFriendsNotifier,
          builder: (context, showFriends, child) {
            return AnimatedFriendsButtons(
              boardSize: widget.boardSize,
              show: showFriends,
              onPlay2Players: () => widget.handler.handleGameSearch(-2, widget.boardSize),
              onPlay4Players: () => widget.handler.handleGameSearch(-4, widget.boardSize),
            );
          },
        ),
      ],
    );
  }
}