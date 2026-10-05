import 'package:flutter_test/flutter_test.dart';
import 'package:poke_dungeon/game/heroes/shield_charge.dart';

void main() {
  test('the shield starts charged', () {
    final shield = ShieldCharge();

    expect(shield.isActive, isTrue);
    expect(shield.chargeRatio, 1);
  });

  test('the shield absorbs one hit then needs to recharge', () {
    final shield = ShieldCharge();

    expect(shield.tryAbsorb(), isTrue);
    expect(shield.isActive, isFalse);
    expect(shield.tryAbsorb(), isFalse);
  });

  test('the shield recharges eight seconds after being consumed', () {
    final shield = ShieldCharge()..tryAbsorb();

    shield.tick(4);
    expect(shield.isActive, isFalse);
    expect(shield.chargeRatio, closeTo(0.5, 0.0001));

    shield.tick(3.9);
    expect(shield.isActive, isFalse);

    shield.tick(0.1);
    expect(shield.isActive, isTrue);
    expect(shield.tryAbsorb(), isTrue);
  });

  test('time spent charged does not bank a second shield', () {
    final shield = ShieldCharge()..tick(100);

    expect(shield.tryAbsorb(), isTrue);
    expect(shield.tryAbsorb(), isFalse);
  });
}
