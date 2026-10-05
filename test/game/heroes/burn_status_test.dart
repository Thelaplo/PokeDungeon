import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/heroes/burn_status.dart';

int burnDamageOver(BurnStatus burn, {required int steps, double dt = 0.5}) {
  var total = 0;
  for (var step = 0; step < steps; step++) {
    total += burn.tick(dt);
  }
  return total;
}

void main() {
  test('a fresh status does not burn', () {
    final burn = BurnStatus();

    expect(burn.isBurning, isFalse);
    expect(burn.tick(1), 0);
  });

  test('a burn deals fifteen percent of the hit every half second', () {
    final burn = BurnStatus()..ignite(100);

    expect(burn.damagePerTick, 15);
    expect(burn.tick(0.25), 0);
    expect(burn.tick(0.25), 15);
  });

  test('a burn lasts three seconds', () {
    final burn = BurnStatus()..ignite(100);

    expect(burnDamageOver(burn, steps: 6), 90);
    expect(burn.isBurning, isFalse);
    expect(burn.tick(0.5), 0);
  });

  test('a long frame still deals every tick it covers', () {
    final burn = BurnStatus()..ignite(100);

    expect(burn.tick(10), 90);
    expect(burn.isBurning, isFalse);
  });

  test('a weak hit still burns for one point', () {
    expect((BurnStatus()..ignite(1)).damagePerTick, 1);
  });

  test('a new hit refreshes the duration and the damage', () {
    final burn = BurnStatus()..ignite(100);
    burnDamageOver(burn, steps: 4);

    burn.ignite(40);

    expect(burn.damagePerTick, 6);
    expect(burnDamageOver(burn, steps: 6), 36);
    expect(burn.isBurning, isFalse);
  });

  test('constant re-hits keep ticking', () {
    final burn = BurnStatus();
    var total = 0;
    for (var step = 0; step < 10; step++) {
      burn.ignite(100);
      total += burn.tick(0.2);
    }

    expect(total, greaterThanOrEqualTo(45));
  });
}
