enum EnemyRank {
  normal(side: 72, scoreMultiplier: 1, damageMultiplier: 1, coinMultiplier: 1),
  boss(side: 136, scoreMultiplier: 2, damageMultiplier: 2, coinMultiplier: 5),
  dailyLegendary(
    side: 160,
    scoreMultiplier: 4,
    damageMultiplier: 2,
    coinMultiplier: 10,
  );

  const EnemyRank({
    required this.side,
    required this.scoreMultiplier,
    required this.damageMultiplier,
    required this.coinMultiplier,
  });

  final double side;
  final int scoreMultiplier;
  final int damageMultiplier;
  final int coinMultiplier;

  bool get isBoss => this != normal;
}
