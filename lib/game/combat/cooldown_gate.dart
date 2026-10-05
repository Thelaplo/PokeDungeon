import 'dart:math';

class CooldownGate {
  CooldownGate({required this.interval});

  final double interval;
  double _remainingSeconds = 0;

  bool get isOpen => _remainingSeconds <= 0;

  bool tryPass() {
    if (!isOpen) {
      return false;
    }
    _remainingSeconds = interval;
    return true;
  }

  void tick(double dt) {
    _remainingSeconds = max(0, _remainingSeconds - dt);
  }
}
