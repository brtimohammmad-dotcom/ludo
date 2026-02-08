class DiceTapLock {
  bool _locked = false;

  bool tryLock() {
    if (_locked) return false;
    _locked = true;
    return true;
  }

  void unlock() {
    _locked = false;
  }

  bool get isLocked => _locked;
}
