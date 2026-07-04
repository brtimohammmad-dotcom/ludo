import 'package:ludo/controller/events/dice_rolled_event.dart';
import 'package:ludo/controller/events/disconnect_event.dart';
import 'package:ludo/controller/events/fast_ping_gets_event.dart';
import 'package:ludo/controller/events/game_event.dart';
import 'package:ludo/controller/events/game_finished_event.dart';
import 'package:ludo/controller/events/game_recovered_event.dart';
import 'package:ludo/controller/events/game_started_event.dart';
import 'package:ludo/controller/events/game_state_update_event.dart';
import 'package:ludo/controller/events/in_another_game_event.dart';
import 'package:ludo/controller/events/move_token_event.dart';
import 'package:ludo/controller/events/not_in_game_event.dart';
import 'package:ludo/controller/events/opponent_exited_event.dart';
import 'package:ludo/controller/events/player_exit_event.dart';
import 'package:ludo/controller/events/player_update_event.dart';
import 'package:ludo/controller/events/player_joined_event.dart';
import 'package:ludo/controller/events/times_up_event.dart';

class GameEventFactory {
  static GameEvent? create(String eventName, Map<String, dynamic> data) {
    switch (eventName) {
      case 'dice_rolled':
        return DiceRolledEvent.fromJson(data);
      case 'token_moved':
        return MoveTokenEvent.fromJson(data);
      case 'game_started':
        return GameStartedEvent();
      case 'game_recovered':
        return GameRecoveredEvent.fromJson(data);
      case 'game_state_update':
        return GameStateUpdateEvent.fromJson(data);
      case 'player_joined':
        return PlayerJoinedEvent.fromJson(data);
      case 'player_update':
        return PlayerUpdateEvent.fromJson(data);
      case 'game_finished':
        return GameFinishedEvent.fromJson(data);
      case 'opponent_exit':
        return OpponentExitedEvent.fromJson(data);
      case 'times_up':
        return TimesUpEvent.fromJson(data);
      case 'fast_ping_gets':
        return FastPingGetsEvent();
      case 'in_another_game':
        return InAnotherGameEvent();
      case 'not_in_game':
        return NotInGameEvent();
      case 'disconnect':
        return DisconnectEvent();
      case 'player_exit':
        return PlayerExitEvent();
      case 'reconnection_failed':
        return PlayerExitEvent();
      default:
        return null;
    }
  }
}
