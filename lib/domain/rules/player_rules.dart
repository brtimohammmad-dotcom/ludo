import 'package:ludo/controller/tokens-controller/tokens_controller.dart';

class PlayerRules {
  bool canActivePlayer({required TokensController tokensController}) {
    final canTokenActive = tokensController.tokenNotifier.value.any(
      (token) => token.isActive,
    );
    return canTokenActive;
  }
}
