import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class WebScrollBehavior extends MaterialScrollBehavior {
  // این متد اجازه می‌دهد با موس و لمس به طور همزمان اسکرول انجام شود
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}