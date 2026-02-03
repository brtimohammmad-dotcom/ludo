import 'package:flutter/material.dart';

class TokenActivationController {
  ValueNotifier<bool> isActiveNotifier = ValueNotifier(false);

  void activeToken(TokenActivationController activationController) {
      activationController.isActiveNotifier.value=true;
      debugPrint('${activationController.isActiveNotifier.value}');
  }
}
