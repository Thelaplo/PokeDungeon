class StatModifiers {
  const StatModifiers({
    this.maxHpBonus = 0,
    this.damageBonus = 0,
    this.damagePercent = 0,
    this.fireRatePercent = 0,
    this.speedPercent = 0,
    this.extraProjectiles = 0,
    this.damageReduction = 0,
    this.regenPerSecond = 0,
    this.magnetRadiusBonus = 0,
    this.healOnHit = 0,
    this.piercing = 0,
    this.diagonalShotPairs = 0,
    this.rearShots = 0,
  });

  final int maxHpBonus;
  final int damageBonus;
  final double damagePercent;
  final double fireRatePercent;
  final double speedPercent;
  final int extraProjectiles;
  final double damageReduction;
  final double regenPerSecond;
  final double magnetRadiusBonus;
  final int healOnHit;
  final int piercing;
  final int diagonalShotPairs;
  final int rearShots;

  List<String> describe() => [
    if (maxHpBonus != 0) '${_signed(maxHpBonus)} PV max',
    if (damageBonus != 0) '${_signed(damageBonus)} dégâts',
    if (damagePercent != 0) '${_percent(damagePercent)} dégâts',
    if (fireRatePercent != 0) '${_percent(fireRatePercent)} cadence',
    if (speedPercent != 0) '${_percent(speedPercent)} vitesse',
    if (extraProjectiles != 0) '${_signed(extraProjectiles)} projectile(s)',
    if (damageReduction != 0) '${_percent(-damageReduction)} dégâts subis',
    if (regenPerSecond != 0) '+${_decimal(regenPerSecond)} PV/s',
    if (magnetRadiusBonus != 0) '+${magnetRadiusBonus.round()} rayon d\'aimant',
    if (healOnHit != 0) '+$healOnHit PV par touche',
    if (piercing != 0) '+$piercing ennemi(s) transpercé(s)',
    if (diagonalShotPairs != 0)
      '+$diagonalShotPairs paire(s) de tirs diagonaux',
    if (rearShots != 0) '+$rearShots tir(s) arrière',
  ];

  StatModifiers scaledBy(double factor) => StatModifiers(
    maxHpBonus: (maxHpBonus * factor).round(),
    damageBonus: (damageBonus * factor).round(),
    damagePercent: _scalePositive(damagePercent, factor),
    fireRatePercent: _scalePositive(fireRatePercent, factor),
    speedPercent: _scalePositive(speedPercent, factor),
    extraProjectiles: extraProjectiles,
    damageReduction: damageReduction * factor,
    regenPerSecond: regenPerSecond * factor,
    magnetRadiusBonus: magnetRadiusBonus * factor,
    healOnHit: (healOnHit * factor).round(),
    piercing: piercing,
    diagonalShotPairs: diagonalShotPairs,
    rearShots: rearShots,
  );

  static double _scalePositive(double value, double factor) =>
      value > 0 ? value * factor : value;

  static String _signed(int value) => value > 0 ? '+$value' : '$value';

  static String _percent(double ratio) {
    final percent = (ratio * 100).round();
    return percent > 0 ? '+$percent %' : '$percent %';
  }

  static String _decimal(double value) => value == value.roundToDouble()
      ? '${value.round()}'
      : value.toStringAsFixed(1);
}
