import 'package:flutter/cupertino.dart';

class DiceTapLock {
  static final ValueNotifier<bool> locked=ValueNotifier(false);

  static bool tryLock() {
    if (locked.value) return false;
    locked.value = true;
    return true;
  }

  static void unlock() {
    locked.value = false;
  }

}
