import 'package:flutter/material.dart';

class TokenActivationController {
  ValueNotifier<bool> isActiveNotifier = ValueNotifier(false);

  void activeToken() {
isActiveNotifier.value = true;
  }

  void disActiveToken() {
    isActiveNotifier.value = false;
  }
}
