import 'dart:math';

class BurnStatus {
  static const duration = 3.0;
  static const tickInterval = 0.5;
  static const damageRatio = 0.15;

  double _remainingSeconds = 0;
  double _tickTimer = 0;
  int _damagePerTick = 0;

  bool get isBurning => _remainingSeconds > 0;

  int get damagePerTick => _damagePerTick;

  void ignite(int hitDamage) {
    if (!isBurning) {
      _tickTimer = tickInterval;
    }
    _damagePerTick = max(1, (hitDamage * damageRatio).round());
    _remainingSeconds = duration;
  }

  int tick(double dt) {
    if (!isBurning) {
      return 0;
    }
    final elapsed = min(dt, _remainingSeconds);
    _remainingSeconds -= elapsed;
    _tickTimer -= elapsed;
    var tickCount = 0;
    while (_tickTimer <= 0) {
      tickCount++;
      _tickTimer += tickInterval;
    }
    final damage = tickCount * _damagePerTick;
    if (!isBurning) {
      _extinguish();
    }
    return damage;
  }

  void _extinguish() {
    _remainingSeconds = 0;
    _tickTimer = 0;
    _damagePerTick = 0;
  }
}
