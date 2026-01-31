import 'package:flutter/material.dart';

class PlayerActivationController {
  ValueNotifier<bool> isActiveNotifier = ValueNotifier(false);

  void activeToken() {
      isActiveNotifier.value = true;
  }
}
