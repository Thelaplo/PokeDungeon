import 'dart:math';

import 'stat_modifiers.dart';

class PlayerStats {
  const PlayerStats({
    required this.maxHp,
    required this.damage,
    required this.fireCooldown,
    required this.speed,
    required this.projectileCount,
    required this.damageReduction,
    required this.regenPerSecond,
    required this.magnetRadius,
    required this.healOnHit,
    required this.piercing,
    required this.diagonalShotPairs,
    required this.rearShots,
  });

  factory PlayerStats.from(Iterable<StatModifiers> modifiers) {
    var maxHpBonus = 0;
    var damageBonus = 0;
    var damagePercent = 0.0;
    var fireRatePercent = 0.0;
    var speedPercent = 0.0;
    var extraProjectiles = 0;
    var damageReduction = 0.0;
    var regenPerSecond = 0.0;
    var magnetRadiusBonus = 0.0;
    var healOnHit = 0;
    var piercing = 0;
    var diagonalShotPairs = 0;
    var rearShots = 0;
    for (final modifier in modifiers) {
      maxHpBonus += modifier.maxHpBonus;
      damageBonus += modifier.damageBonus;
      damagePercent += modifier.damagePercent;
      fireRatePercent += modifier.fireRatePercent;
      speedPercent += modifier.speedPercent;
      extraProjectiles += modifier.extraProjectiles;
      damageReduction += modifier.damageReduction;
      regenPerSecond += modifier.regenPerSecond;
      magnetRadiusBonus += modifier.magnetRadiusBonus;
      healOnHit += modifier.healOnHit;
      piercing += modifier.piercing;
      diagonalShotPairs += modifier.diagonalShotPairs;
      rearShots += modifier.rearShots;
    }
    return PlayerStats(
      maxHp: max(1, baseMaxHp + maxHpBonus),
      damage: max(
        1,
        ((baseDamage + damageBonus) * (1 + damagePercent)).round(),
      ),
      fireCooldown: baseFireCooldown / max(_minRateFactor, 1 + fireRatePercent),
      speed: baseSpeed * max(_minRateFactor, 1 + speedPercent),
      projectileCount: max(1, 1 + extraProjectiles),
      damageReduction: damageReduction.clamp(0.0, maxDamageReduction),
      regenPerSecond: regenPerSecond,
      magnetRadius: baseMagnetRadius + magnetRadiusBonus,
      healOnHit: healOnHit,
      piercing: max(0, piercing),
      diagonalShotPairs: max(0, diagonalShotPairs),
      rearShots: max(0, rearShots),
    );
  }

  static const baseMaxHp = 100;
  static const baseDamage = 15;
  static const baseFireCooldown = 0.3;
  static const baseSpeed = 180.0;
  static const baseMagnetRadius = 70.0;
  static const maxDamageReduction = 0.6;
  static const _minRateFactor = 0.3;

  final int maxHp;
  final int damage;
  final double fireCooldown;
  final double speed;
  final int projectileCount;
  final double damageReduction;
  final double regenPerSecond;
  final double magnetRadius;
  final int healOnHit;
  final int piercing;
  final int diagonalShotPairs;
  final int rearShots;

  double get shotsPerSecond => 1 / fireCooldown;

  int reduceIncomingDamage(int incomingDamage) =>
      max(1, (incomingDamage * (1 - damageReduction)).round());
}
