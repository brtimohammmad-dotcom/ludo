import 'package:flutter/cupertino.dart';
import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/domain/model/token.dart';

class EmojiReceivedEvent implements GameEvent {
  final String emoji;
  final PlayerColor playerColor;

  EmojiReceivedEvent({required this.emoji, required this.playerColor});

  factory EmojiReceivedEvent.fromJson(Map<String, dynamic> data) {
    debugPrint(data.toString());
    final playerColor = PlayerColor.values.byName(data['playerColor']);
    return EmojiReceivedEvent(
        emoji: data['emoji'] as String, playerColor: playerColor);
  }

  @override
  void execute(GameController controller) {
    debugPrint('emoji show');
    controller.showEmoji(playerColor, emoji);
  }
}
