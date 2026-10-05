import 'dart:math';

class ShieldCharge {
  static const rechargeDuration = 8.0;
  static const _timeEpsilon = 1e-9;

  double _rechargeTimer = 0;

  bool get isActive => _rechargeTimer <= _timeEpsilon;

  double get chargeRatio =>
      isActive ? 1 : 1 - _rechargeTimer / rechargeDuration;

  bool tryAbsorb() {
    if (!isActive) {
      return false;
    }
    _rechargeTimer = rechargeDuration;
    return true;
  }

  void tick(double dt) {
    if (isActive) {
      return;
    }
    _rechargeTimer = max(0, _rechargeTimer - dt);
  }
}
